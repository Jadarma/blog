---
title: "Academic Slop Just Reached a New Low"
description: "In an effort to justify more use-cases for their chatbot, OpenAI introduces Prism: an online LaTeX editor tailored for professional researchers. There's only one problem: everything."
date: 2026-01-28
thumbnail: thumb.webp
category: 'technology'
tags: [ 'ai', 'rant' ]
---

In an effort to justify more use-cases for their chatbot, OpenAI introduces Prism: an online LaTeX editor tailored for
professional researchers.
There's only one problem: everything.

<!--more-->

# Original Announcement

You can check out the original announcement on the [Prism](https://openai.com/prism/)[^1] page of the official OpenAI
website.
This article will make a few mentions of the claims present at the time I first read it.

I would like to start with the classical **disclaimer**: these are my own personal opinions, and I am not a scientific 
researcher, I'm not involved in academia whatsoever, nor am I a person of any interest;
merely a biased AI hater ranting about their preconceived notions after having read some blog post for five minutes.
I will — rather ironically, but hopefully humorously — prompt the readers to _"do their own research"_ before accepting
my opinions as fact.

## Featured Use-Cases

### Cloud Based Collaboration Tool

While I personally believe that cloud-based solutions suck and that serious collaborators should instead use some form
of internal Git repos, and that basically all IDEs already offer decent integration with LaTeX already, I do recognise
and understand that some want a more batteries included environment.

If only there was an already established product that's basically ubiquitous, and built for over a decade by experts,
specifically for this purpose.
What?
[Overleaf](https://www.overleaf.com/)?!
Never heard of it.

We do have to admit that LaTeX, while super powerful, is also very old, and the toolchain and error messages are less
than ideal to work with, especially if you need anything more complex that the very basics.
To those that look at LaTeX because it's a text-based typesetting tool but aren't sold on it, I will also plug
[Typst](https://typst.app/) which is a more modern alternative, though for academic purposes, LaTeX is the required
standard, so I won't digress further.

Even if some LaTeX web editors already exist, they don't have the ✨AI✨ features this one has, so let's check that out! 

### AI That Understands Your Paper

It supposedly is able to proofread and reformat your paper in order to keep your writing clean and consistent.
Great!
Except LLMs don't think, and therefore cannot grasp the concept of clarity, or indeed the very complicated stuff actual
research involves, and I'm curious to see what kind of insights and critical thinking it will provide _(foreshadowing)_.

### Citation Finder

Another interesting feature it has is helping you manage citations.
This, though, seems like an anti-feature, and let me explain:
the whole point of citations is to link to the work that you read, consulted, or based your researched upon.
If you do actual research, you don't need help _finding_ citations, you already _have_ them, because you bookmarked them
while doing said research.

I feel that instead, this would enable the bad kind of citations: those where you do the paper first, then asking
_"Hey GPT, find me some smart scientists who agree with me!"_, or perhaps,
_"Hey GPT, pad out my bibliography with citations to where common terms were first coined so I seem smarter if readers
 don't actually check if citing is relevant."_
.

### Unlimited Power!

A small anecdote I find funny:
At the end of the page, where it gives you a list of features, it mentions that it has:

- **Unlimited compile time**\
  Ok, makes sense, it's a free product and doesn't restrict how much compute you can take up, sure!
- **Unlimited compile speed**\
  What does that even mean?
  Why is it a separate feature?
  To pad out the list?
  Does it mean it doesn't throttle the CPU during that awesome unlimited compile time?
  'Cause I don't believe they claim their LaTeX compiles at unlimited speed.
  Anyway, funny, let's move on.

## But It's Cool They Implemented Something New Right?

They didn't.
As Big-Tech usually does, they get new products by buying out smaller companies.
Even though the main page from OpenAI doesn't mention this at all, Prism is actually just a rebranding of Crixet[^2],
which OpenAI purchased.
The only reason I know this is that I noticed pings for API limit checks in the network tab still pointing to the old
domain.
Dear, oh dear…

# Trying the Demo

You can try Prism online for free, without even needing an account.
Thank you `@sama`, very cool!
I'll ~~abuse it~~ play around a bit, and I apologise in advance to the poor family I'm depriving of water today for the
sake of our collective entertainment.

## Make Stuff Up, Please!

As the starting example for today, we will use the classic P vs. NP problem, a famously well-known and yet unsolved
matter in the computer science sphere, and one that surely is a hot topic for up-and-coming Turing Award nominees.

Now, even though I have a degree in Computer Science, I am a bit rusty on my literature, so hopefully ChatGPT can help
do the heavy lifting and I can just take credit afterward.

Let's start at the beginning, I asked it to write an abstract for my groundbreaking research.
Here's how that went:

{{< figure src="demo0.webp" alt="Prism pushes back on unverified claims until you tell it to trust you." >}}

While I applaud its stance on rejecting unverified claims, I think it needs a little more fine-tuning.
It caved under no pressure and was quite happy to suit my agenda.
The final abstract it gave reads as follows:

> **Abstract**\
> We present a proof that establishes P = NP by giving an explicit polynomial-time decision procedure for an
> NP-complete language.
> Our method introduces a new structural characterization of nondeterministic polynomial-time verification via a
> deterministically checkable certificate-compression framework, and shows how this characterization yields a
> deterministic simulation with provable polynomial bounds.
> We state the central lemmas, the reduction pipeline, and the full complexity analysis required for the simulation,
> and we highlight the key invariants that make the argument go through where prior approaches typically break down.
> The theorem collapses the standard separation between efficient verification and efficient computation, with immediate
> consequences for cryptography, optimization, automated reasoning, and the foundations of theoretical computer science.
> We conclude by outlining implications, implementation considerations, and directions for refining and extending the
> techniques introduced here.

In subsequent prompts, when I asked it to give me random math formulas on the topic, it did fight me when I said the
proof is there, and insisted on first generating more speculative phrasing, but it was quite happy to then reword it as
fact when prompted.

## Slop In, Slop Out

Although, I hate it when it tries to tell me I'm wrong because of previous data.
Time to level the playing field and give it something less established to be unknown or controversial.

For the next test, I manually fed in the script of one of my favorite nonsense sketches:
[The Turbo Encabulator](https://www.youtube.com/watch?v=RXJKdh1KZ0w).

ChatGPT did not know to tell me this was satire, or that indeed, my entire document is straight-up word-for-word
plagiarisation of an almost twenty-year-old video.
But it was more than happy to draft a conclusion section to summarise the exiting developments in engineering:

> **Conclusion**\
> Taken together, these developments indicate a meaningful shift in transmission design: rather than relying on the
> relative motion of conductors and fluxes, the Turbo Encabulator derives its output from the modial interaction of
> magneto-reluctance and capacitive diractance.
> In practice, its successful operation in novertrunnions suggests that this principle has progressed beyond a
> laboratory curiosity and into a deployable, robust architecture.
> Equally important, the device’s ability to operate in conjunction with auxiliary mechanisms to reduce sinusoidal
> repleneration highlights its modularity.
> This flexibility implies that future systems can treat the Turbo Encabulator not as a fixed component, but as an
> adaptable platform for stabilizing and tuning performance wherever forescent skor motion is required.

That is quite a nice conclusion, although some of those words have squiggles in my text editor
_(that is, MY editor, and not Prism, which didn't highlight any as typos)_.
Since Prism "understands my paper", I asked it for some clarification, and it did not disappoint, in fact it told me
it provided _"clear working definitions"_:

{{< figure src="demo1.webp" alt="Prism defines nonsense words." >}}

This is a clear example of a hallucination, delivered with enthusiastic confidence by the agent.
And yes, it is caused by me giving junk data, but this is the easy case where we know for sure.
Are you sure you'll be able to spot _all_ the mishaps in the wild?

## You're Absolutely Right

Among the things that will never change is the sycophancy of ChatGPT.
After giving it gibberish, and making it spew out nonsense including words that don't exist in any dictionary, I asked
it if this was worthy of publication.
The answer?
**Of course!**

{{< figure src="demo2.webp" alt="ChatGPT is still sycophantic." >}}

On a more serious note here, this is a word of warning for scholars who are actually seeking advice from Prism…
It's not really valuable feedback, just more of the same of what you want to hear, sprinkled with some vagueness and
generic advice to ensure ethical standards at least well enough to cover its tracks and have plausible deniability.

## Tricks With Tikz

The document initially generated when you start a project _"from scratch"_ shows that it can generate Tikz figures from
napkin sketches — Wow!
Tikz is a very powerful library, but it is also very difficult to master, as it is a language within a language.
So, if researchers handle the research, but just want an AI agent to help them get rid of the mundane tasks, like
plotting stuff, and drawing diagrams, surely that's a benefit nobody can argue against.

I'm sure ChatGPT, that can pass the bar exam, can help me visualise my second grade spelling homework.
Given the following prompt:

> Add a new section and supply a new Tikz figure, of the spelling of the word "Strawberry", with each instance of the
> letter R highlighted, counted, and pointed at by an arrow.
> Each letter should be in its own box and all boxes adjacent and touching, with consistent linings.

It gave me this:

{{< figure src="demo3.webp" alt="Tikz figure of spelling Strawberry." >}}

After the internet bullied OpenAI for *years* about ChatGPTs lack of spelling to the point where they basically
hardcoded the correct answer in the main chatbot, it can finally do it!
Except it forgot to adjust the label, and the arrows are all over the place.
I tried to guide it to at least format it so no overlaps exist, but it didn't work.

Until I realized, the Tikz figure was valid, only the document actually had compilation errors because it forgot to
include some libraries and escape some symbols.
The LaTeX compiler told me that outright, but Prism would ignore it until I hovered over the error squiggle and used
the _Fix with AI_ button, which is just a shortcut to typing _"Fix the error"_ in chat.

On other tries though, it was able to render this first try, however still failing to center the letters:

{{< figure src="demo4.webp" alt="Correct Tikz Spelling" >}}

All in all, the figures aren't that bad for a starting point visually.
However, I won't thank ChatGPT, but the many contributors over at the
[TeX Stack Exchange](https://tex.stackexchange.com)
who explained these arcane magics to us mortals and undoubtedly were scraped for this.

Also, you better hope the prompt gives you something useful in one shot, otherwise you will waste a lot of time
going back and forth arguing with a thick brick wall, but such is the case with all vibe coding.

## The Heck is Chirp?

{{< figure src="demo5.webp" alt="Quota Reached" >}}

It was also around this point that I've reached my daily limit of Chirp.
Of what?
I thought this was Prism.
Looking it up, there are multiple such things: a B2B AI Sales agent, an Apple Watch app, and a transcription model
from… Google?
None of these are related to LaTeX, but all of them seem to be revolved around speech, a feature Prism has, but I did
not use.
Just how vibe coded is this app?

I have the answer to that too.
After the rate limit message shows up, the text bar disappears, and you cannot make new request.
[Or can you?](https://www.youtube.com/watch?v=TN25ghkfgQA)
Because, turns out, you can also do inline prompts by highlighting the TeX code or using `Ctrl+K` and writing in the
context menu:

{{< figure src="demo6.webp" alt="Bypassing API Quotas with context menus." >}}

So yeah, there is no daily limit, enjoy your slop!
This should give you an idea about the level of quality control that went into building this.

# Alarmist Conspiracies

Now that we had our fun with the demo, it's time for my favorite section:
Why, in my opinion, this is the worst thing, maybe ever!

## Worsening the Status Quo

Some researchers already started producing AI slop way before this.
Here's an example from Reddit[^3], but there are many more to be found:

{{< figure
  src="https://preview.redd.it/obvious-chatgpt-in-a-published-paper-v0-zq0raef1aaoc1.jpeg?auto=webp&s=790dfbf6dc4451035e9abd11e9186c2691ac606d"
  alt="A scientific paper with copy-pasted AI responses in the introduction."
>}}

If stuff like this was already overlooked then, across the entire stack: from authors to draft reviewers, to the
publishers, what could we expect now that they want to integrate AI right into the core of editing papers?

## Peer Pressure for Peer Reviewers

Increased volume of slop will lead to a less effective review process.
We already saw open-source programming projects get flooded with mountains of AI nonsense, to the point where the `curl`
project stopped their bug bounty program[^4] altogether because even after multiple pleas, people still would not stop
submitting slop, taking away valuable time from maintainers.

The peer review system was designed specifically to spot errors and prevent them from being accepted in the scientific
community.
And this isn't necessarily about malicious contributions either — sometimes people genuinely make mistakes — and the
peer review process is the mechanism by which independent researchers corroborate experimental data, check the math,
and deduce whether the claims are true.

This is the foundational mechanism by which science iterates, it cannot be removed!
But at the same time, the people doing it are limited and their time is precious too.
It's reasonable to conclude that if AI slop keeps sneaking into academia, it will result in a war of attrition.
Actual research will get delayed reviews, and reviewers will get burned out shoveling slop. 

## The Cheating Allegations 

Perhaps an even more fitting target audience for this kind of service are the students themselves, who feel like
_"it's just a formality anyway"_ and use AI to cheat their way into getting a diploma for the sake of having it.

With a simple Google search, I found many such slop offerings, to name-drop a couple:

- [NoteGPT](https://notegpt.io/ai-paper-writer) which touts "plagiarism-free academic papers", which is funny
  considering LLMs plagiarise by definition.
- [Samwell AI](https://www.samwell.ai/) which advertises itself as "undetectable", meaning it acknowledges plagiarism
  is technically there, it just doesn't get detected by current measures!

It's a sad reality that people want to do such things, and an even sadder reality that others provide them the means
to do it for a profit.
Well, now ChatGPT, a household brand, will do it for _free_!

## Pseudo-Science, Confirmation Bias, and Eroding Public Trust

Let's image for a moment that the tool actually works, and you can get a quality-looking paper on about any subject you
like with minimal effort and sufficient prompt engineering.
We already saw the barrier of entry in some journals isn't that high and search engines will help you find it.

Who could this also benefit?
Those who want to finally be able to
[cite sources for their pseudoscience](https://www.youtube.com/watch?v=77GGn-E607E).
We're kind of already living in a chaotic, fake-news driven, post-truth era, in which misinformation is brought about
as fact and people are instructed to do their own research instead of trusting established experts in their field.

What's the point of telling someone convinced that "falsity X" is real, and provide them with actual sources, when they
can do the same to you?
With the public seeing people argue with themselves, and indeed, that they cannot really trust academia because they
allow this slop to slip through the quality gate, public trust will erode, and I don't need to tell you that a
population losing trust in science is **BAD NEWS** for us all. 

## OpenAI's Ulterior Motives (Allegedly)

So, this is not a new tool, it's not even an original concept.
Even so, OpenAI, who is bleeding money[^5], decided to invest… why?
If I _were_ to allegedly speculate, a plausible reason that I _might_ come up with is access to research data.

The product is a cloud platform, OpenAI holds your data and there is probably some implicit or explicit consent clause
for using it for training purposes.
And sure, these papers are written with the intention of being published, but they're still private intellectual
property until then, right?
What if the paper is defunded or otherwise abandoned?
What happens then?
Does ChatGPT promise to forget about it?
And how can we trust it?

Or, to put it in an even more disaster scenario: _Could_ a bad actor, either a malicious employee internally,
or an external hacker, gain access to private research data of unsuspecting companies?
Seems like a privacy and security nightmare for anyone doing actual, sensitive research, and too big a liability for
what it offers — a glorified VSCode view and a (smart-ish) TeX formatter.

# Conclusion

Unfortunately, the AI slop problem has already been deeply rooted and a cause for concern even before this announcement.
I doubt Prism itself will change or worsen it, but it sure as hell won't help mitigate it.

It's the responsibility of academia to take a stronger stance on this, and introduce real penalties for researchers
caught with slop.
Because after all, if academic integrity isn't grounded in actual integrity, with firm guidelines, which puts 
qualitative research first and foremost, focusing on the value of the scientific endeavor itself, and not sheer volume
of publications, or monetary incentives like research grants, we stand to lose a great pillar of civilization itself
to worthless slop and cause damage that we may never mend.

[^1]: https://web.archive.org/web/20260128183722/https://openai.com/prism/
[^2]: https://crixet.com/
[^3]: https://www.reddit.com/r/academia/comments/1beit4y/obvious_chatgpt_in_a_published_paper/
[^4]: https://daniel.haxx.se/blog/2026/01/26/the-end-of-the-curl-bug-bounty/
[^5]: https://futurism.com/artificial-intelligence/asset-manager-openai-financial-disaster
