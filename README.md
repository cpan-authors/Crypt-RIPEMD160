# NAME

Crypt::RIPEMD160 - Perl extension for the RIPEMD-160 Hash function

# SYNOPSIS

    use Crypt::RIPEMD160;
    
    $context = Crypt::RIPEMD160->new;
    $context->reset();
    
    $context->add(LIST);
    $context->addfile(HANDLE);

    $digest = $context->digest();
    $string = $context->hexdigest();

    $copy = $context->clone();

    $digest = Crypt::RIPEMD160->hash(SCALAR);
    $string = Crypt::RIPEMD160->hexhash(SCALAR);

# DESCRIPTION

The **Crypt::RIPEMD160** module allows you to use the RIPEMD160
Message Digest algorithm from within Perl programs.

The module is based on the implementation from Antoon Bosselaers from
Katholieke Universiteit Leuven. 

A new RIPEMD160 context object is created with the **new** operation.
Multiple simultaneous digest contexts can be maintained, if desired.
The context is updated with the **add** operation which adds the
strings contained in the _LIST_ parameter. Note, however, that
`add('foo', 'bar')`, `add('foo')` followed by `add('bar')` and
`add('foobar')` should all give the same result.

The final message digest value is returned by the **digest** operation
as a 20-byte binary string. This operation delivers the result of
**add** operations since the last **new** or **reset** operation. Note
that the **digest** operation is effectively a destructive, read-once
operation. Once it has been performed, the context must be **reset**
before being used to calculate another digest value.

Several convenience functions are also provided. The **addfile**
operation takes an open file-handle and reads it until end-of file in
8192 byte blocks adding the contents to the context. The file-handle
can either be specified by name or passed as a type-glob reference, as
shown in the examples below. The **hexdigest** operation calls
**digest** and returns the result as a printable string of hexdecimal
digits. This is exactly the same operation as performed by the
**unpack** operation in the examples below.

The **clone** operation creates an independent copy of the current
context, preserving all accumulated state. This is useful for computing
digests of data that share a common prefix without re-processing the
shared portion.

The **hash** operation can act as either a static member function (ie
you invoke it on the RIPEMD160 class as in the synopsis above) or as a
normal virtual function. In both cases it performs the complete RIPEMD160
cycle (reset, add, digest) on the supplied scalar value. This is
convenient for handling small quantities of data. When invoked on the
class a temporary context is created. When invoked through an already
created context object, this context is used. The latter form is
slightly more efficient. The **hexhash** operation is analogous to
**hexdigest**.

# EXAMPLES

    use Crypt::RIPEMD160;
    
    $ripemd160 = Crypt::RIPEMD160->new;
    $ripemd160->add('foo', 'bar');
    $ripemd160->add('baz');
    $digest = $ripemd160->digest();
    
    print("Digest is " . unpack("H*", $digest) . "\n");

The above example would print out the message

    Digest is f137cb536c05ec2bc97e73327937b6e81d3a4cc9

provided that the implementation is working correctly.

Remembering the Perl motto ("There's more than one way to do it"), the
following should all give the same result:

    use Crypt::RIPEMD160;
    $ripemd160 = Crypt::RIPEMD160->new;

    open(my $fh, '<', '/etc/passwd')
        or die "Can't open /etc/passwd: $!\n";

    seek($fh, 0, 0);
    $ripemd160->reset;
    $ripemd160->addfile($fh);
    $d = $ripemd160->hexdigest;
    print "addfile (lexical filehandle) = $d\n";

    seek($fh, 0, 0);
    $ripemd160->reset;
    while (<$fh>)
    {
        $ripemd160->add($_);
    }
    $d = $ripemd160->hexdigest;
    print "Line at a time = $d\n";

    seek($fh, 0, 0);
    $ripemd160->reset;
    $ripemd160->add(<$fh>);
    $d = $ripemd160->hexdigest;
    print "All lines at once = $d\n";

    seek($fh, 0, 0);
    $ripemd160->reset;
    while (read($fh, $data, int(rand(128)) + 1))
    {
        $ripemd160->add($data);
    }
    $d = $ripemd160->hexdigest;
    print "Random chunks = $d\n";

    seek($fh, 0, 0);
    $ripemd160->reset;
    local $/;
    $data = <$fh>;
    $d = $ripemd160->hexhash($data);
    print "Single string = $d\n";

    close($fh);

# NOTE

The RIPEMD160 extension may be redistributed under the same terms as Perl.
The RIPEMD160 algorithm is published in "Fast Software Encryption, LNCS 1039,
D. Gollmann (Ed.), pp.71-82".

The basic C code implementing the algorithm is covered by the
following copyright:

> `
> /********************************************************************\
>  *
>  *      FILE:     rmd160.c
>  *
>  *      CONTENTS: A sample C-implementation of the RIPEMD-160
>  *                hash-function.
>  *      TARGET:   any computer with an ANSI C compiler
>  *
>  *      AUTHOR:   Antoon Bosselaers, ESAT-COSIC
>  *      DATE:     1 March 1996
>  *      VERSION:  1.0
>  *
>  *      Copyright (c) Katholieke Universiteit Leuven
>  *      1996, All Rights Reserved
>  *
> \********************************************************************/
> `

# RIPEMD-160 test suite results (ASCII):

`
* message: "" (empty string)
  hashcode: 9c1185a5c5e9fc54612808977ee8f548b2258d31
* message: "a"
  hashcode: 0bdc9d2d256b3ee9daae347be6f4dc835a467ffe
* message: "abc"
  hashcode: 8eb208f7e05d987a9b044a8e98c6b087f15a0bfc
* message: "message digest"
  hashcode: 5d0689ef49d2fae572b881b123a85ffa21595f36
* message: "abcdefghijklmnopqrstuvwxyz"
  hashcode: f71c27109c692c1b56bbdceb5b9d2865b3708dbc
* message: "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
  hashcode: 12a053384a9c0c88e405a06c27dcf49ada62eb2b
* message: "A...Za...z0...9"
  hashcode: b0e20b6e3116640286ed3a87a5713079b21f5189
* message: 8 times "1234567890"
  hashcode: 9b752e45573d4b39f4dbd3323cab82bf63326bfb
* message: 1 million times "a"
  hashcode: 52783243c1697bdbe16d37f97f68f08325dc1528
`

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl you may have available.

See [https://dev.perl.org/licenses/](https://dev.perl.org/licenses/) for more information.

# AUTHOR

The RIPEMD-160 interface was written by Christian H. Geuer-Pollmann (CHGEUER)
(`geuer-pollmann@nue.et-inf.uni.siegen.de`) and Ken Neighbors (`ken@nsds.com`).

# SEE ALSO

MD5(3pm) and SHA(1).
