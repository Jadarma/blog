---
title: "The Best Prank JavaScript Ever Pulled On Me"
description: "An astronomically improbable thing happened at an unbelievably comical time."
date: 2025-01-31
category: 'technology'
tags: [ 'javascript', 'humor', 'software' ]
---

A short story about the time when software catches you by surprise, and doing silly things in the most
unexpected way.

<!--more-->

I was visiting my friends; we were watching a movie[^1] from the couch on the TV and HTPC, using one of those
[mini wireless keyboards](https://m.media-amazon.com/images/I/716IMb8AiAL._AC_SL1500_.jpg)[^2], and,
as it usually goes, someone ends up sitting on it.

A popup shows up, the crowd goes _"d'awwwwh 😠"_ and I grab the keyboard attempting to fix it.
I came closer to read it, it stated:

{{< figure src="popup.webp" 
    alt="You have asked Vimium to perform 5467 repetitions of the command: undefined. Are you sure you want to continue? Cancel / OK"
    >}}

That by itself was the funniest thing I've seen all day, what is this?
Why does Vimium think I want five thousand of something?
Of course JavaScript doesn't care and just goes undefined.
But how did a random butt-dial do this?

To be fair, while I am criticising the lack of JavaScript's error handling, I have to admire the extension's defensive
programming.
It saw some idiot tell it to do something five thousand times, and it tried to ask if we were right in the noggin'.

_"Are you sure?"_ — Well, I am pretty sure this will never happen again, my curiosity is peaked.
You know what, JavaScript? I _DO_ want to see you perform five thousand repeats of `undefined`!
***OK!***

The result?
The opening of five thousand four hundred and sixty-seven new tabs.
Needless to say, we were all floored.
The movie was still playing while I had a laughing fit, trying to navigate back to the right tab, navigating through the
sea of new tabs.
Of course, that didn't go well, so it was time to close the browser.
When I opened it again, we were again greeted with five thousand tabs, because it's set to reopen the last session.
Thankfully, Firefox endured it, and holding down _Ctrl+W_ was enough to clean up the mess in 30 seconds.
The movie was resumed, and all was well.

For those who want the frog dissected, I was able to reproduce this issue by having a glance at Vimium's documentation[^3].
The butt-dial in question must've been: **`5467t`**, which indeed tells Vimium to open that many tabs, and it also fits
the steps to reproduce, since all the keys involved are conveniently neighboring each-other, perfect for an accident.
Why does the documented _"Open new tab"_ command show up as _"undefined"_ in the pop-up?
Only JavaScript knows.

But I will always remember that even when I least expect it, JavaScript will still find a way to haunt me.
And of all the ways JavaScript makes me cry, I'm glad laughter is also a viable option.

[^1]: [With Honors (1994)](https://www.themoviedb.org/movie/16297-with-honors) — I recommend it.
[^2]: [This Rii-Mini Thing](https://www.amazon.de/-/en/Rii-Mini-Wireless-Keyboard-Touchpad-black/dp/B07CCFSYFX) — _(Meh, does the job, not an endorsement!)_
[^3]: [Vimium](https://vimium.github.io/)
