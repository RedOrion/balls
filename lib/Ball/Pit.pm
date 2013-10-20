package Ball::Pit;

# A pit containing many balls (2D representation only)

use Moose;
use Ball::Quantum;
use namespace::autoclean;
use Data::Dumper;

# An array of all the balls in the pit
#
has 'balls' => (
    is      => 'rw',
    isa     => 'ArrayRef[Ball::Quantum]',
    default => sub { [] },
);
# The height of the pit (in pixels)
#
has 'width' => (
    is      => 'rw',
    isa     => 'Int',
    default => 1000,
);
# The width of the pit (in pixels)
#
has 'height' => (
    is      => 'rw',
    isa     => 'Int',
    default => 1000,
);
# The 'time' (in seconds) from when the ball pit was created
# 
has 'time' => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);

# Create a ball pit with random balls
#
sub BUILD {
    my ($self) = @_;

    for (my $i=0; $i < 10; $i++) {
        my $radius = int(rand(10)+10);
        # somewhere in the centre
        my $start_x = rand($self->width - 400) + 200;
        my $start_y = rand($self->height - 400) + 200;
        my $duration = rand(10000) + 5000;              # 5 to 10 seconds
        my $end_x = rand($self->width * 3) - $self->width;
        $end_x = $radius if ($end_x < $radius);
        $end_x = $self->width - $radius if $end_x > ($self->width - $radius);
        my $end_y = rand($self->height * 3) - $self->height;
        $end_y = $radius if ($end_y < $radius);
        $end_y = $self->height - $radius if $end_y > ($self->width - $radius);

        my $ball = Ball::Quantum->new({
            id          => $i,
            start_time  => 0,
            end_time    => $duration,
            start_x     => $start_x,
            start_y     => $start_y,
            end_x       => $end_x,
            end_y       => $end_y,
        });
        push @{$self->balls}, $ball;
    }
    # extend the time up to 10 seconds ahead
    $self->update(30000);
    print STDERR Dumper($self->balls);

}

# Update the pit by a number of seconds
#   Anything that finishes before the end time is re-computed
#   anything that finishes before the start time can be deleted
sub update {
    my ($self, $duration) = @_;

    # As a test, we just bounce the ball back to it's start, rather than compute collisions.
    my @newballs;
    my $end_time = $self->time + $duration;
    foreach my $ball (@{$self->balls}) {
        my $to_time     = $ball->end_time;
        my $duration    = $to_time - $ball->start_time;
        my $this_ball   = $ball;
        while ($to_time <= $end_time) {
            print STDERR "to_time=$to_time end_time=$end_time duration=$duration\n";
            if ($to_time > $self->time) {
                # The ball has not reached it's destination.
                push @newballs, $this_ball;
            }
            my $new_ball = Ball::Quantum->new({
                id          => $this_ball->id,
                start_time  => $this_ball->end_time,
                end_time    => $this_ball->end_time + $duration,
                start_x     => $this_ball->end_x,
                start_y     => $this_ball->end_y,
                end_x       => $this_ball->start_x,
                end_y       => $this_ball->start_y,
            });
            push @newballs, $new_ball;
            $this_ball = $new_ball;
            $to_time = $new_ball->end_time;
        }
    }
    $self->balls(\@newballs);

}


# Create a hash representation of the object
#
sub to_hash {
    my ($self) = @_;

    my @balls_quantum_ref;
    foreach my $ball_quantum (@{$self->balls}) {
        push @balls_quantum_ref, $ball_quantum->to_hash
    }
    return {
        width   => $self->width,
        height  => $self->height,
        balls   => \@balls_quantum_ref,
    };
}

__PACKAGE__->meta->make_immutable;


