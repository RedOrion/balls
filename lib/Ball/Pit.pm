package Ball::Pit;

# A pit containing many balls (2D representation only)

use Moose;
use namespace::autoclean;
use Data::Dumper;

has 'balls' => (
    is      => 'rw',
    isa     => 'ArrayOf[Ball::Quanta]',
    default => [],
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

    for (my $i=0; $i++; $i < 10) {
        my $radius = int(rand(10)+10);
        # somewhere in the centre
        my $start_x = rand($self->width - 400) + 200;
        my $start_y = rand($self->height - 400) + 200;
        my $duration = rand(10000) + 5000;              # 5 to 10 seconds
        my $end_x = rand($self->width * 3) - $self->width;
        $end_x = $radius if $end_x < $radius;
        $end_x = $self->width - $radius if $end_x > ($self->width - $radius);
        my $end_y = rand($self->height * 3) - $self->height;
        $end_y = $radius if $end_y < $radius;
        $end_y = $self->height - $radius if $end_y > ($self->width - $radius);

        my $ball = Ball::Quanta->new({
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

__PACKAGE__->meta->make_immutable;


