In scientific collaborations, one will almost inevitably have to use Microsoft (MS) Word at some point in order to write and edit papers collaboratively.  Statistical software tends to have exportability to Word and Excel in order to add text and tables.  MS Word has a lot of good tools that were state of the art and unique for word processing.  Most other word processing systems have integrated these tools, such as Word Count and Track Changes, which are integral to preparing documents and manuscripts for publication.

But when collaborating with multiple people, Word can become an absolute nightmare.  
For example, one paper we were trying to edit had over 5 authors and the version of the Word document was "FINAL_VERSION_jm_ab_dc_cm_dc2.doc".  First thing, it was anything but the final version.   Secondly, every author got the FINAL_VERSON.doc and then edited, and the author had to merge these.  On top of that, one got the edited version and re-edited (dc2) (all initial are made up except jm), and it was unclear if they truly used the "FINAL_VERSION_jm_ab_dc_cm", or the "FINAL_VERSION_jm_ab" again, etc.  

### Ideal Editor
In my perfect world, editing a paper would involve getting all collaborators together in a room, each with a copy of the manuscript, which they have read in advance.  The group would then go over the document piece by piece, discussing comments and delegating changes.  This would happen a few times until the authors agreed on the outcome of the paper.  This process would allow for people to clearly communicate their comments and for the group collectively to agree on changes.  Of course, this is almost never possible with more than 2-3 collaborators, due to physical location and scheduling issues.  However, this parallel editing process can be simulated with smart collaboration tools, such as Google Docs. 


### Collaboratively editing with Word: Parallel vs. Series
#### In Parallel
The reason Word can’t emulate the parallel editing process is because it’s not online.  There is another approach to collaborative editing other than distributing the documents in parallel and that is in series.  In my experience, distributing parallel is the more common approach in my experience.  In parallel distribution, the lead author sends out the document to all co-authors and gets versions back, which are often indexed by some terrible versioning system (e.g. filename_co-author-initials.doc).  The lead author then merges the document together, trying to integrate multiple comments on the same sections, making decisions on which suggestions to take and which to discard.   This has the benefit that the co-authors are all reviewing simultaneously (in parallel) at the same time (roughly) and so this can be quick.  It also allows people to have the same document at the same time, so page numbers, paragraphs, and sections are standard across all authors.  However, while this process is generally good for a co-author, it’s not always good for the paper, since multiple commenting co-authors may not be able to argue different viewpoints on editing the same section.  Also, the burden usually falls squarely on the lead author, which can reduce turnaround time on documents and usually involves the aforementioned subjective choices between edits. 

#### In Series
In serial distribution, the lead author sends the document to each co-author one at a time, waits for edits/comments, makes the appropriate changes, and then distributes the updated document to the next co-author.  This allows for comments to be evaluated at each step and incorporated or discarded, which can allow for better integration.  This process has a variety of problems.  One drawback is that it can be held up by one co-author.  Another potential problem is that changing a later version of a section with respect to comments from co-author $j$ after co-author $i$ has edited may change how co-author i views that section, ($j$ > $i$).  This can be partially remedied by either doing 2 passes, which is more time consuming, or doing an in-parallel distribution after the initial in-series distribution.  Perhaps most worrisome is the effect of the order of author distribution, as an initial author (usually more junior) may have higher weight on changing the document than the later authors (usually more senior), such as taking out plots/sections that later authors find useful.   

## Google Docs
Now, I obviously prefer the in-parallel distribution as it lines up more with my ideal editing process.  In that vein, I believe Google Docs dominates over MS Word for distribution.  Here's why:

Almost everyone has access to Google, and can edit even if they don't have an account
Google Docs has track changes, versioning, and comments, just like MS Word.
Google Docs also has a chat feature, so that multiple people can discuss the document without editing the document that everyone can see (i.e. no one is left out on an email)
Authors can edit simultaneously (usually good) and can see the location of other people’s cursors or highlighting.  This is important when having conferences/discussions (fewer "what section are you talking about" questions).
The document doesn’t spawn into several static author-specific versions - instead a single live document is edited by all authors Google Docs has .docx exportability (as well as pdf, txt, html, rtf).

### Why not Dropbox?
 The Google Drive application incorporates Dropbox-style versioning and live updating, which is why I do not think Dropbox has any major benefit over Google Drive.

### Potential reasons against Google Docs
Setbacks that need to be remedied for more widespread use:
  * Better (in some cases any) integration into EndNote, Zotero, Mendeley or some other referencing software.
  * Adding line numbers (which is usually necessary for submission)
  * More seamless export to .docx - no reformatting necessary
  * Better figure/table referencing/aliasing so that when you change table 2 to table 3, all the references update


We have tried using Google Docs with multiple co-authors, and honestly it was much easier.  People could update figures, sections, and references all independently and conferences were much easier as everyone could see where the speaker could refer to.  Not all may agree with my comments above, especially those that incorporate the in-series distribution strategy, but for one project urge the lead to try Google Docs as a test case.

Overall, I just think going online is the way to go if you need to collaborate with multiple co-authors on a document.  The main culprit here is not really Word, but using email to send Word documents and get feedback.  Emails get deleted, not everyone necessary is cc'd, files of the same name can be attached that are truly different, etc.   Therefore, having one centralized document that allows editing, commenting, and discussion is the best logical choice. But hopefully, it will lead to the end of the awful email-Word duo.

### Note:
Disclaimer: I'm talking about collaoborating a crowd where GitHub is not an option.  
These are not only problems with Word, but changing is better simply because Word has an online alternative.  With LaTeX for example, there are still formidable setbacks that are in place, some more so than with Word, such as no live-editing of the PDF.   If you want to send the LaTeX source, the co-authors need to know LaTeX and have all packages installed and figures/tables attached.  There are online editing tools such as [ShareLaTeX](https://www.sharelatex.com/), which are used even more sparsely compared to Google Docs, even within the LaTeX community.  Thus, I believe the collaborator model will shift towards a larger online editing model than the one currently in place, but the tools must be there.  

