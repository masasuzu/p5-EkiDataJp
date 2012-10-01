NAME
================

EkiDataJp - 駅データJPのデータを良い感じにしてくれる人

SYNOPSIS
================

::

    use EkiDataJp;
    my $edata = EkiDataJp->new(
        input_file => './resouce/m_station.csv',
        output_dir => './tmp',
    );

    # yamlにデータをダンプしてくれるよ
    $edata->dump_yaml;

DESCRIPTION
================

駅データJPお駅データが正規化されてなくて、使いにくいのでパースだけしてくれる人。

元データの利用規約は元データ提供元に準拠します。

http://www.ekidata.jp/download/index.html

AUTHOR
================

masasuzu / SUZUKI Masashi <m15.suzuki.masashi@gmail.com>

LICENSE
================

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
