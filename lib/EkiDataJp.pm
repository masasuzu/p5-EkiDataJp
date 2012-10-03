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
        [qw( companies lines line_company stations station_line station_group )]
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

    open my $fh, "<:encoding(euc_jp)", ( $self->input_file ) or die 'cannot open file';
    my @header = @{ $ts->getline($fh) };

    my $result = +{};
    while (my $line = $ts->getline($fh)) {
        my %row =();
        @row{@header} = @$line;

        my $row = \%row;
        for my $table (@{ $self->tables }) {
            my $method = "__build_$table";
            $self->$method($row, $result);
        }
    }

    close $fh;

    for my $table (@{ $self->tables }) {
        $result->{$table} = "EkiDataJp::Data::@{[ camelize($table) ]}"->new( data => [ values %{ $result->{$table} } ]);
    }
    return $result;
}

sub __build_lines {
    my ($self, $row, $result) = @_;
    $result->{lines}->{$row->{line_cd}} ||= +{
        line_name => $row->{line_name},
        line_cd   => $row->{line_cd},
        line_sort => $row->{line_sort},
        r_type    => $row->{r_type},
    };
}

sub __build_stations {
    my ($self, $row, $result) = @_;
    $result->{stations}->{$row->{station_cd}} ||= +{
        station_name => $row->{station_name},
        station_cd   => $row->{station_cd},
        pref_cd      => $row->{pref_cd},
        lat          => $row->{lat},
        lng          => $row->{lon},
    };
}


sub __build_companies {
    my ($self, $row, $result) = @_;
    $result->{companies}->{$row->{rr_cd}} ||= +{
        rr_cd   => $row->{rr_cd},
        rr_name => $row->{rr_name},
    };
}

sub __build_line_company {
    my ($self, $row, $result) = @_;
    $result->{line_company}->{$row->{line_cd}} ||= +{
        line_cd => $row->{station_cd},
        rr_cds  => [ $row->{rr_cd} ],
    };
    unless( grep { $_ eq $row->{rr_cd} } @{ $result->{line_company}->{$row->{line_cd}}->{rr_cds} } ) {
        push @{ $result->{line_company}->{$row->{line_cd}}->{rr_cds} }, $row->{rr_cd};
    }
}

sub __build_station_line {
    my ($self, $row, $result) = @_;
    $result->{station_line}->{$row->{station_cd}} ||= +{
        station_cd => $row->{station_cd},
        line_cds   => [ $row->{line_cd} ],
    };
    unless( grep { $_ eq $row->{line_cd} } @{ $result->{station_line}->{$row->{station_cd}}->{line_cds} } ) {
        push @{ $result->{station_line}->{$row->{station_cd}}->{line_cds} }, $row->{line_cd};
    }
}

sub __build_station_group {
    my ($self, $row, $result) = @_;
    $result->{station_group}->{$row->{station_g_cd}} ||= +{
        station_g_cd => $row->{station_g_cd},
        station_cds   => [ $row->{station_cd} ],
    };
    unless( grep { $_ eq $row->{station_cd} } @{ $result->{station_group}->{$row->{station_g_cd}}->{station_cds} } ) {
        push @{ $result->{station_group}->{$row->{station_g_cd}}->{station_cds} }, $row->{station_cd};
    }
}

sub dump_yaml {
    my ($self,) = @_;
    my $output_dir = $self->output_dir;
    mkdir $output_dir;
    for my $table (@{ $self->tables }) {
        DumpFile("$output_dir/$table.yaml", $self->parsed_data->{$table}->data )
    }
}

sub dump_sql {
    my ($self,) = @_;
    die 'not impremented';
}

__PACKAGE__->meta->make_immutable();

1;
