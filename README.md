#Spamassassin Concepts

Spamassassin Concepts is a plug in that canonicalises emails into their basic concepts. These concepts are then available to Bayes to work with as well as being available via meta scoring.
It offers a simple alternative to the native SA meta rules, by being easier to write and understand.

##Installation

 - Download zip
 - Move to spamassassin location
	 - Usually /etc/mail/spamassassin or /etc/spamassassin
 - Make sure [Bayes](https://wiki.apache.org/spamassassin/BayesFaq) is enabled
 - Update Concepts.cf with correct path to the concepts directory
 - Restart Spamassassin

###Testing Installation

With a test email run spamassassin in debug mode, searching for the *Concepts* keyword

    $ spamassassin -D -t testemail 2>&1 | grep Concepts
    ...
    [12201] dbg: plugin: loading Mail::SpamAssassin::Plugin::Concepts from /etc/spamassassin/Concepts.pm
    ...

This means the plugin has loaded.
You should also get an output with a digest of the concepts gained from your example email

    [12201] dbg: Concepts: metadata: X-SA-Concepts: service madam dear stranger invest sir reply2me please email-adr

For problems please follow the error messages

##Usage

In day to day life you do not need to interact with Concepts - Bayes will automatically keep up to date with what is considered good and bad as long as you classify your spam and ham carefully.

**Be careful with manual scoring!!! By design concepts can hit both ham and spam emails - including combinations you couldn't imagine! **

If you would like to interact with Concepts you can in the form of meta rules to give matching email additional weighting

    header __CONCEPTS_GOD X-SA-Concepts =~ /\bgod\b/
    header __CONCEPTS_AFRICA X-SA-Concepts =~ /\bafrica\b/
    header __CONCEPTS_LOTSMONEY X-SA-Concepts =~ /\lotsofmoney\b/
    header __CONCEPTS_STRANGER X-SA-Concepts =~ /\bstranger\b/
    header __CONCEPTS_DYING X-SA-Concepts =~ /\bdying\b/
    
    #scores 4 or more
    meta GOD_IN_AFRICA_LOTSAMONEY_STRANGERS_DYING (__CONCEPTS_GOD + __CONCEPTS_AFRICA + __CONCEPTS_LOTSMONEY + __CONCEPTS_STRANGER + __CONCEPTS_DYING >= 4)
    describe GOD_IN_AFRICA_LOTSAMONEY_STRANGERS_DYING Combo
    score GOD_IN_AFRICA_LOTSAMONEY_STRANGERS_DYING 1.0 

##Example

Normally logs will not show, however by switching logging to debug mode you will see similar in your logs

    May 22 23:12:22 spamfilter spamd[7459]: metadata: X-SA-Concepts: hotwords law sale https contact time-ref order privacy internet store apple report invoice all-rights email-adr price receipt
    May 22 23:12:23 spamfilter spamd[1998]: metadata: X-SA-Concepts: friend law re optout important online time-ref all-rights please news home privacy
    May 22 23:12:26 spamfilter spamd[3128]: metadata: X-SA-Concepts: https optout day-of-week
    May 22 23:12:33 spamfilter spamd[1998]: metadata: X-SA-Concepts: friend https linkedin twitter america opportunity contact experience club search-eng optout winner time-ref facebook prize mailto re important online click all-rights email-adr please newsletter day-of-week partner
    May 22 23:12:35 spamfilter spamd[3128]: metadata: X-SA-Concepts: time-ref https optout
    May 22 23:12:38 spamfilter spamd[1998]: metadata: X-SA-Concepts: hotwords money optout discount online click news hot-adj
    May 22 23:12:39 spamfilter spamd[1998]: metadata: X-SA-Concepts: alert service
    May 22 23:12:43 spamfilter spamd[1998]: metadata: X-SA-Concepts: hotwords offer search-eng optout facebook details discount doitnow hello price watches https sale twitter sentfrom contact time-ref deal great home deals store score health camera click please email-adr
    May 22 23:12:43 spamfilter spamd[3128]: metadata: X-SA-Concepts: hotwords law offer claim optout online time-ref click compensation best
    May 22 23:12:44 spamfilter spamd[3129]: metadata: X-SA-Concepts: internet law voip time-ref click all-rights email-adr please
    May 22 23:12:46 spamfilter spamd[3129]: metadata: X-SA-Concepts: https contact time-ref notice order email-adr day-of-week
    May 22 23:12:47 spamfilter spamd[9513]: metadata: X-SA-Concepts: thankyou reply2me contact details online woman please
    May 22 23:12:47 spamfilter spamd[10502]: metadata: X-SA-Concepts: friend google india linkedin boost america phone-num money search-eng optout time-ref home invest internet store apple member re important details email-adr please asian security news newsletter day-of-week
    May 22 23:12:47 spamfilter spamd[7459]: metadata: X-SA-Concepts: offer search-eng optout facebook enjoy details discount doitnow hello price watches https sale twitter sentfrom contact time-ref deal woman great home deals store health camera click game please email-adr


##Change Log
###Version 0.01
 - Initial release
 - 250 concept files
 - Native tags and Bayes integration
 - Native meta rules based on concepts
