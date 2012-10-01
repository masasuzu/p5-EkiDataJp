use strict;
use warnings;
package EkiDataJp::Data;

use Mouse;

has data => (
    is       => 'ro',
    isa      => 'ArrayRef[HashRef]',
    required => 1,
);

__PACKAGE__->meta->make_immutable();

package EkiDataJp::Data::Stations;
use Mouse;
extends 'EkiDataJp::Data';
__PACKAGE__->meta->make_immutable();

package EkiDataJp::Data::StationLine;
use Mouse;
extends 'EkiDataJp::Data';
__PACKAGE__->meta->make_immutable();

package EkiDataJp::Data::Lines;
use Mouse;
extends 'EkiDataJp::Data';
__PACKAGE__->meta->make_immutable();

package EkiDataJp::Data::StationGroup;
use Mouse;
extends 'EkiDataJp::Data';
__PACKAGE__->meta->make_immutable();

package EkiDataJp::Data::Company;
use Mouse;
extends 'EkiDataJp::Data';
__PACKAGE__->meta->make_immutable();

1;
