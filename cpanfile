requires 'Digest' => 0;
requires 'XSLoader' => 0;
requires 'Carp' => 0;

on "test" => sub {
    requires "Test::More" => "0";
};

on "develop" => sub {
    requires "Test::Pod" => "1.00";
    requires "Test::Pod::Coverage" => "1.00";
};
