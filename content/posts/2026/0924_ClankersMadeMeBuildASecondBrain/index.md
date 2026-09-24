---
title: "Clankers Made Me Build a Second Brain"
description: "AI was the last straw that convinced me I need a PKM system."
date: 2026-09-24
thumbnail: thumb.webp
category: 'technology'
series: 'obsidian'
tags: [ 'ai', 'rant' ]
---

AI was the last straw that convinced me I need a PKM system.

<!--more-->

# Prompt-In, Slop-Out

I'm a developer, I know a little about a lot, and I tinker with lots of niche things for fun.
Personally, I'm the stereotypical AI skeptic, hate how the technology works, and I refuse to vibe code.

That being said, I am not a saint, and my work laptop has forced Claude down my gullet anyway _(yay, "free" tokens!)_.
Sometimes, when I'm deep in the flow, I don't want to interrupt myself to quickly Google something
_"I should already know by heart"_, especially if I can help getting it over with already.

When I have to bodge up an ad hoc CI shell script, I sometimes commit the cardinal sin of asking Claude real quick how
that Bash-ism went, and if it was `2>&1` or `2&>1` -- you know the type.

Now, granted, most of the time it does its job, I close the chat, and don't give it a second thought.
Other times it ruffles my ever-loving feathers, because in its attempt to please me rather than help me, it says stuff
like:

> In order to do feature X, simply pass the `--do-X` flag to the end of the command.

I open up the `man` page to double-check, of course it's not there, so I retaliate, and it goes:

> You're absolutely right, my bad, let me look up a different source.

Other times, it saves me the trouble of telling it that it's stupid by having a mid-context window aneurysm and
gaslighting itself with responses like:

> In order to do feature X, simply pass the `--do-X` flag to the end of the command...
> No wait, hold on... actually that flag isn't real, I actually meant to say (...)

As I frustratingly rolled my eyes at the magic terminal window disobeying my intent and making fun of its inadequacy,
I realized that -- although with a heavy dose of both amusement and lowered expectations --
I have nonetheless succumbed to the mundane temptation of asking a clanker to 
_"tell me what I need to know, make no mistakes"_...
Shame on me! 🔔

# Don't Delegate Understanding

The title of this section is a reference to Steph Ango's post with the same name [^1].
It more poetically describes the dangers of these _"convenience tools"_ infesting and exploiting you to the benefit of
_others_.
Although the metaphor applies to many things even before its time, AI is probably the one that fits the best.
The article ends with the following wisdom:

> _To inoculate yourself don’t delegate understanding.
> If you build your own understanding you will be the one who earns the dividends._

He is _absolutely right_ here, and I didn't pick this by accident.
Steph is the CEO of [Obsidian](https://obsidian.md/), a very popular Markdown editor that many use to write and explore
their personal notes collection.

It's also a perfect segue into a solution for my predicament...

# Just Write Notes Instead

The problems I was trying to solve weren't new.
I wasn't asking the AI to give me information I never heard of before.
I was asking it specifically about something I knew was a thing, that I've done before, but it was longer ago, so I
wasn't sure of the specific details.
Something that normally would be accomplished by a Google search leading to a Stack Overflow answer, ah...
those were the days!
Alas, that has since enshittified too _(also because of AI)_.

If I had, when I first learned about that feature, also taken the time to write a short note on it, then months later
I would have had the exact answer *I* wanted, in the form that *I* expected to find it, along with the explanation that
made it click for *me*, and might not even have to look it up because, in the process of taking said note, I would've
needed to use my brain to synthesize the information, which in turn would've bolstered my _understanding_ of it.

Sure, one could make the argument that some knowledge gets stale, especially in the domain of programming.
I'd retort that's just inevitable, even if you had a photographic memory and perfectly recalled everything you ever
learned without writing it down, you'd _still_ be wrong eventually.
Although it's mildly annoying, finding out _my_ answer is an outdated hallucination and then amending it is a preferable
alternative to me than starting from scratch every time with just good vibes, a search bar, and an internet full of
slop.
Not to mention that you can take notes about things you can't just look up: your thoughts, opinions, ideas, memories.

If there is a system that is able to contain such wealth of knowledge while keeping it useful, it's Obsidian.

# Hey Jarvis, Tell Me What I Think Today

The first time I heard of Obsidian was probably around the early pandemic.
It looked like a shiny new toy and I wanted to see how the best people use it, but never took it upon myself to
actually give it a go because starting out was so daunting, considering just how many competing schools of thought
around organizing your vault existed even then.

It was a wonderful rabbit hole in which I watched hour long videos by various creators, comparing and contrasting their
opinions on the best workflow or structure, showing you tutorials, etc., even if in the end I watched them more for
entertainment value.
The main criticism I had with those was that it seemed to me like all the staunch _"second brain"_ advocates made less
of a useful note system, and more of a middle-management style productivity theater, bolstering pretty dashboards with
fancy graphs and arbitrary metrics.

Of course, with time, it only got _worse_...
Because the notes are Markdown files, the same file extension as a `SKILL.md`, vibe coders quickly put two and two
together and concluded the next big revolution in managing your second brain is to feed that one slop as well.

I won't mention any names _(if you've been around, you know who they are)_, but I do want to share with you
Eric Morrison's video on [second brain cringelords](https://youtu.be/6NukGtwJb7Y)[^2], because it is
tragically funny, and shows the antithesis of Steph's post:
_delegating as much understanding as possible_.
It's gotten to the point where it's genuinely fair to summarize their workflow as satire:

> _Hey Claude, please watch this content for me, extract the important bits, form an opinion in my stead, then put all
> that next to my most personal thoughts and ideas.
> When I ask a question later, make sure to evaporate several gallons of water to load my vault into your context window
> before answering, and in the process, dump all my personal knowledge directly into Dario's lap for further analysis._

At first glance, it might seem condensing language is the perfect use-case for a _language model_, but it's not.
It only mimics productivity, and doesn't teach you anything.
These people think that by faking the motions of putting notes in a folder they somehow add value, it's nothing short
of a cargo cult[^3].
The _real_ reason why taking notes helps people is that taking notes requires writing, and writing is thinking[^4].

# But Why The Interest In The Second Brain Then?

I did spend awhile mocking the concept, but just because we were looking at the extreme side of things.
I do want to clarify that none of this has any bearing on my opinion of Obsidian, which you shouldn't think of as
_"the second brain app"_, it's just a Markdown editor.
A well-made, featureful, private, and user-respecting one at that, but I'll elaborate on that in another article.

The points I'm making are that:

- Taking notes _(both to keep track of knowledge, and mere journaling)_ is useful in and of itself.
- I love writing Markdown _(this blog is just Markdown too, after all)_.
- I would need to use fewer searches and chatbots if I kept common useful snippets myself.
- **I should probably make the most out of the internet while it's still useful.**

What do I mean by that last one?
It's a bit of hyperbole, but one seeded in undeniable cynicism.
Since the billionaire oligarchy decided to optimize for click-through rather than quality, and the rat racers can make
easier money through slop than through effort, the internet is already degrading at an alarming rate.
Not talking about the AI memes and ads on social media, although that *is* a pretty big deal too.

Have you noticed how much pseudo-content you find when you look up tutorials nowadays?
You Google something to find an AI article on it, or a fake answer board with an AI making up answers on the spot.
To stay on topic, I am a visual learner, I like searching for videos on stuff, even low-level questions, because I value
seeing what knowledge others have to share, or learn from their mistakes, or whatever.
Naturally, I wanted to refresh my memory on all the nice features Obsidian had, find tips and tricks, what have you.

I stumbled across _so... much... slop..._
AI content farms just creating useless short videos with a soulless narrator TTS-ing the copy-pasted GPT response that
gives you the same amount of insight as the first paragraph of the documentation.

Let me give you a few basic examples.
In my search results on _"Obsidian linking best practices"_, the algorithm snuck in recommendations like
[this](https://www.youtube.com/watch?v=H8SOlEuXiGw) or [that](https://www.youtube.com/watch?v=tHEqyAat0jM).
To their credit, at least they didn't start the video by explaining why 
_["the creamy, rich texture of peanut butter pairs exceptionally well with the smooth and sweet flavor of chocolate"](https://www.youtube.com/watch?v=oIliSPK0uEs)_.

Mhh... yes... haha funny!
Instantly detectable as slop from the thumbnail, just scroll past!
But if I were to play into the predictions of AI accelerationists, it will only get better, so it can stand to reason
that a few more years down this hellish line, very realistic slop will waste _a lot_ more of your time.
Even worse, it might drown out genuine creators to the point that they _(or we)_ might abandon platforms altogether.
Not a wild concept, it's happening already[^5].

# Conclusion

I think it's as good a time as any to start making a personal vault and save the useful information you need in your
day-to-day and once-in-a-blue-moon alike, local and offline, forever.
It's definitely _not_ for everyone, but I think more people would be into the idea if they gave it an honest go, and I
am willing to try.

I also want to point out I am not advocating for hoarding knowledge to one's self.
Collect your knowledge so you may better share it with others later.
Good people need to communicate and collaborate -- otherwise we lose.

As always, I'll document my journey in the hopes it will be helpful to others, and plan to expand
[this series]({{< ref "series/obsidian/_index.md" >}}) in the
future.

[^1]: https://stephango.com/understand
[^2]: https://youtu.be/6NukGtwJb7Y
[^3]: https://en.wikipedia.org/wiki/Cargo_cult
[^4]: https://www.nature.com/articles/s44222-025-00323-4
[^5]: https://youtu.be/-Gnrp_caPvo
