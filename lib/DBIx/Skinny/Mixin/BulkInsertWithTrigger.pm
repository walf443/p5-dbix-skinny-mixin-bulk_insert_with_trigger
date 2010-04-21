package DBIx::Skinny::Mixin::BulkInsertWithTrigger;

use strict;
use warnings;
our $VERSION = '0.01';

sub register_method {
    +{
        bulk_insert_with_pre_insert_trigger => \&bulk_insert_with_pre_insert_trigger,
    };
}

sub bulk_insert_with_pre_insert_trigger {
    my ($class, $table, $args, $init_auto_increment_pk) = @_;

    my $schema = $class->schema;
    my $pk = $schema->schema_info->{$table}->{pk};

    for my $arg ( @{ $args } ) {
        $class->call_schema_trigger('pre_insert', $schema, $table, $arg);
        if ( defined $init_auto_increment_pk ) {
            $arg->{$pk} = $init_auto_increment_pk;
            $init_auto_increment_pk++; # is it always int?
        }
    }
    $class->bulk_insert($table, $args);
    # XXX: should call post_insert ? I don't need to fetch inserted data for calling post_insert hook.
}

1;
__END__

=head1 NAME

DBIx::Skinny::Mixin::BulkInsertWithTrigger -

=head1 SYNOPSIS

    package YourProj::DB;
    use DBIx::Skinny;
    use DBIx::Skinny::Mixin modules => [ 'BulkInsertWithTrigger'];

    package main;

    YourProj::DB->bulk_insert_with_trigger(your_table => [
        { id => 1, name => 'foo' },
        { id => 2, name => 'bar' },
    ]);

pre_insert trigger is executed for each item before bulk_insert.
post_insert trigger is executed for each item after bulk_insert.

=head1 DESCRIPTION

DBIx::Skinny::Mixin::BulkInsertWithTrigger is

=head1 AUTHOR

Keiji Yoshimi E<lt>walf443 at gmail dot comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
