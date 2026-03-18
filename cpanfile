#requires "Git::Repository"             => 0;
#recommends "YAML"             => "0";
requires 'DynaLoader' => 0;
requires 'Carp' => 0;

on "test" => sub {
    requires "Test::More" => "0";
};

# on 'develop' => sub {
#     recommends 'Devel::NYTProf';
# };
