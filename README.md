<!---
SPDX-License-Identifier: AGPL-3.0-or-later
Copyright (c) 2022 Red Hat GmbH
Author: Stefano Brivio <sbrivio@redhat.com>
-->

<link rel="stylesheet" type="text/css" href="/static/asciinema-player.css" />
<script src="/static/asciinema-player.min.js"></script>

<div id="demo_mbuto_div" style="display: grid; grid-template-columns: 1fr 1fr;">
  <div id="demo_base" style="width: 99%;"></div>
  <div id="demo_kselftests" style="width: 99%;"></div>
</div>

<script>
AsciinemaPlayer.create('/static/base.cast',
		       document.getElementById('demo_base'),
		       { cols: 80, rows: 22, preload: true, loop: true,
			 autoPlay: true, poster: 'npt:0:2' });

AsciinemaPlayer.create('/static/kselftests.cast',
		       document.getElementById('demo_kselftests'),
		       { cols: 80, rows: 22, preload: true, loop: true,
			 autoplay: true, poster: 'npt:0:2' });
</script>
