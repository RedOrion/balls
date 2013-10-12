package Ball::Pit;

# A pit containing many balls (2D representation only)

use Moose;
use namespace::autoclean;

has 'balls' => (
    is      => 'rw',
    isa     => 'ArrayOf[Ball::Quanta]',
    default => [],
);

__PACKAGE__->meta->make_immutable;


