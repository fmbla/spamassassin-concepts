#Spamassassin Concepts
----------
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

##Change Log
###Version 0.1
 - Initial release
 - 250 concept files
 - Native tags and Bayes integration
 - Native meta rules based on concepts
