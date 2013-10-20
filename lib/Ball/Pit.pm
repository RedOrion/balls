package Ball::Pit;

# A pit containing many balls (2D representation only)

use Moose;
use Ball::Quantum;
use namespace::autoclean;
use Data::Dumper;

has 'balls' => (
    is      => 'rw',
    isa     => 'ArrayRef[Ball::Quantum]',
    default => sub { [] },
);

has 'width' => (
    is      => 'rw',
    isa     => 'Int',
    default => 1000,
);

has 'height' => (
    is      => 'rw',
    isa     => 'Int',
    default => 1000,
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
    print STDERR Dumper($self->balls);

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


