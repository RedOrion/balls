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
has 'start_time' => (
    is      => 'rw',
    isa     => 'Int',
    default => -1,
);
has 'end_time' => (
    is      => 'rw',
    isa     => 'Int',
    default => -1,
);
# The duration (in milliseconds) from each calculation
#
has 'duration' => (
    is      => 'rw',
    isa     => 'Int',
    default => 2000,
);

# Create a ball pit with random balls
#
sub BUILD {
    my ($self) = @_;

    my @balls;
    for (my $i=0; $i < 100; $i++) {
        my $radius = int(rand(10)+10);
        # somewhere in the centre
        my $start_x = rand($self->width - 400) + 200;
        my $start_y = rand($self->height - 400) + 200;
        my $duration = rand(30000) + 15000;              # 5 to 10 seconds
        my $end_x = rand($self->width * 3) - $self->width;
        $end_x = $radius if ($end_x < $radius);
        $end_x = $self->width - $radius if $end_x > ($self->width - $radius);
        my $end_y = rand($self->height * 3) - $self->height;
        $end_y = $radius if ($end_y < $radius);
        $end_y = $self->height - $radius if $end_y > ($self->width - $radius);

        my $ball = Ball::Quantum->new({
            id          => $i,
            start_time  => 1,
            end_time    => int($duration),
            start_x     => int($start_x),
            start_y     => int($start_y),
            end_x       => int($end_x),
            end_y       => int($end_y),
        });
        print STDERR "### $i ###\n";
        push @balls, $ball;
    }
    $self->balls(\@balls);
    # extend the time up to 1 second ahead
    print STDERR "#########\n". Dumper($self->balls);
    $self->update($self->duration);
}

# Update the pit by a number of seconds
#   Anything that finishes before the end time is re-computed
#   anything that finishes before the start time can be deleted
sub update {
    my ($self, $duration) = @_;

    # As a test, we just bounce the ball back to it's start, rather than compute collisions.
    my @newballs;
    my $start_time;
    my $end_time;
    if ($self->start_time < 0) {
        # then this is the first time.
        $start_time = 0;
        $end_time   = $start_time + $duration;
    }
    else {
        $start_time = $self->start_time + $duration;
        $end_time   = $self->end_time + $duration;
    }
    print STDERR "FROM $start_time TO $end_time\n";
    BALL:
    foreach my $ball (@{$self->balls}) {
        print STDERR "BALL ".$ball->start_time." to ".$ball->end_time." ";
        if ($ball->end_time <= $start_time) {
            print STDERR " ERASED\n";
            next BALL;
        }
       
        my $ball_duration = $ball->end_time - $ball->start_time;
        print STDERR "\n";
    
        while ($ball->end_time <= $end_time) {
            push @newballs, $ball;
            my $new_ball = Ball::Quantum->new({
                id          => $ball->id,
                start_time  => int($ball->end_time),
                end_time    => int($ball->end_time + $ball_duration),
                start_x     => int($ball->end_x),
                start_y     => int($ball->end_y),
                end_x       => int($ball->start_x),
                end_y       => int($ball->start_y),
            });
            $ball = $new_ball;
            print STDERR "ADD  ".$ball->start_time." to ".$ball->end_time."\n";
        }
        push @newballs, $ball;
    }
    $self->start_time($start_time);
    $self->end_time($end_time);
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
                time    => $self->start_time,
        balls   => \@balls_quantum_ref,
    };
}

__PACKAGE__->meta->make_immutable;


