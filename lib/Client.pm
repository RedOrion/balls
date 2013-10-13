package Client;

use Moose;
use namespace::autoclean;

has 'tx' => (
    is          => 'rw',
    required    => 1,
);

has 'id' => (
    is          => 'rw',
);

has 'name' => (
    is          => 'rw',
    isa         => 'Str',
    default     => 'bar',
);

__PACKAGE__->meta->make_immutable;
