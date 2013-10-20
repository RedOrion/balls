package Ball::Quantum;

# A representation of a ball, moving between two places, in time

use Moose;
use namespace::autoclean;


extends "Ball";

# Start time in milliseconds
has 'start_time' => (
    is      => 'rw',
    isa     => 'Num',
    default => 0,
);
# end time in milliseconds
has 'end_time' => (
    is      => 'rw',
    isa     => 'Num',
    default => 0,
);
# start X co-ordinate (in pixel space)
has 'start_x' => (
    is      => 'rw',
    isa     => 'Num',
    default => 0,
);
# start Y co-ordinate
has 'start_y' => (
    is      => 'rw',
    isa     => 'Num',
    default => 0,
);
# end X co-ordinate
has 'end_x' => (
    is      => 'rw',
    isa     => 'Num',
    default => 0,
);
# end Y co-ordinate
has 'end_y' => (
    is      => 'rw',
    isa     => 'Num',
    default => 0,
);


sub to_hash {
    my ($self) = @_;

    return {
        start_time  => $self->start_time,
        end_time    => $self->end_time,
        start_x     => $self->start_x,
        start_y     => $self->start_y,
        end_x       => $self->end_x,
        end_y       => $self->end_y,
    };
}

__PACKAGE__->meta->make_immutable;
