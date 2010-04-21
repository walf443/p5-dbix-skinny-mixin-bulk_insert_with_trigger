use t::Utils;
use Mock::Trigger;
use Test::More;

Mock::Trigger->setup_test_db;

subtest 'bulk_insert method' => sub {
    subtest 'pre_insert trigger should work in bulk_insert_with_pre_insert_trigger' => sub {

        Mock::Trigger->bulk_insert_with_pre_insert_trigger('mock_trigger_pre' => [
            {
                id   => 1,
                name => 'perl',
            },
            {
                id   => 2,
                name => 'ruby',
            },
            {
                id   => 3,
                name => 'python',
            },
        ]);

        is +Mock::Trigger->count('mock_trigger_pre', 'id'), 3;
        for ( my $i = 1; $i < 3; $i++ ) {
            my $item = Mock::Trigger->single(mock_trigger_pre => +{ id => $i});
            is($item->name, "pre_insert_s", "pre_insert should work");
        }

        done_testing()
    };

    subtest 'post_insert trigger should not work in bulk_insert_with_pre_insert_trigger' => sub {
        Mock::Trigger->bulk_insert_with_pre_insert_trigger('mock_trigger_pre' => [
            {
                id   => 1,
                name => 'perl',
            },
            {
                id   => 2,
                name => 'ruby',
            },
            {
                id   => 3,
                name => 'python',
            },
        ]);

        is +Mock::Trigger->count('mock_trigger_post', 'id'), 0, "post_insert trigger should not work";

        done_testing()
    };

    subtest 'with init_auto_increment_pk' => sub {

        Mock::Trigger->bulk_insert_with_pre_insert_trigger('mock_trigger_pre' => [
            {
                name => 'perl',
            },
            {
                name => 'ruby',
            },
            {
                name => 'python',
            },
        ], auto_increment_pk_init => 7);

        is +Mock::Trigger->count('mock_trigger_pre', 'id'), 9;
        for ( my $i = 7; $i < 9; $i++ ) {
            my $item = Mock::Trigger->single(mock_trigger_pre => +{ id => $i});
            ok($item, 'item should exist');
            is($item->name, "pre_insert_s", "pre_insert should work");
        }

        done_testing;
    };

    done_testing;
};

done_testing;
