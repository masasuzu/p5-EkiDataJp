use strict;
use warnings;
use utf8;
package EkiDataJp;

use EkiDataJp::Data;

use Mouse;
use String::CamelCase qw( camelize );
use Text::CSV_XS;
use YAML::Syck;

has input_file => (
    is      => 'rw',
    isa     => 'Str',
    default => './m_station.csv',
);

has output_dir => (
    is      => 'rw',
    isa     => 'Str',
    default => './tmp',
);

has tables => (
    is      => 'ro',
    isa     => 'ArrayRef[Str]',
    default => sub {
        [qw( company lines stations station_line station_group )]
    },
);

has parsed_data => (
    is         => 'ro',
    isa        => 'HashRef',
    lazy_build => 1,
);

sub _build_parsed_data {
    my ($self,) = @_;

    my $ts = Text::CSV_XS->new;

    open my $fh, "<:encoding(euc_jp)", ( $self->input_file ) or die ;

    my $result = +{};

    my @header = @{ $ts->getline($fh) };
    while (my $line = $ts->getline($fh)) {
        my %row =();
        @row{@header} = @$line;
        $result->{lines}->{$row{line_cd}} ||= +{
            line_name => $row{line_name},
            line_cd   => $row{line_cd},
            line_sort => $row{line_sort},
        };
        $result->{stations}->{$row{station_cd}} ||= +{
            station_name => $row{station_name},
            station_cd   => $row{station_cd},
            pref_cd      => $row{pref_cd},
            lat          => $row{lat},
            lng          => $row{lon},
        };

        $result->{company}->{$row{rr_cd}} ||= +{
            rr_cd   => $row{rr_cd},
            rr_name => $row{rr_name},
        };

        $result->{station_group}->{$row{station_g_cd}} ||= +{
            station_g_cd => $row{station_g_cd},
            station_cd   => [ $row{station_cd} ],
        };
        unless( grep { $_ eq $row{station_cd} } @{ $result->{station_group}->{$row{station_g_cd}}->{station_cd} } ) {
            push @{ $result->{station_group}->{$row{station_g_cd}}->{station_cd} }, $row{station_cd};
        }
    }
    close $fh;

    for my $table (@{ $self->tables }) {
        $result->{$table} = "EkiDataJp::Data::@{[ camelize($table) ]}"->new( data => [ values %{ $result->{$table} } ]);
    }
    return $result;
}

sub dump_yaml {
    my ($self,) = @_;
    my $output_dir = $self->output_dir;
    mkdir $output_dir;
    for my $table (@{ $self->tables }) {
        DumpFile("$output_dir/$table.yaml", $self->parsed_data->{$table}->data )
    }
}

__PACKAGE__->meta->make_immutable();

1;
