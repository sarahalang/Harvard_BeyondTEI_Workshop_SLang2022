<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:strip-space elements="*"/> <!-- for LaTeX -->
    <xsl:output method="text" encoding="UTF-8" indent="no" omit-xml-declaration="yes"/>
    
    <!-- REGEX to clean up the resulting LaTeX from unnecessary line breaks:
        Apply only to the section of the LaTeX code where reledmac starts.
        First, replace single linebreaks by space: (\w+|\W+)\n(\w+|\W+) by '$1 $2'.
        Fix trailing punctuation (if any left): (\w+)\n\.\n(\w+) by '$1. $2'. 
        Then replace multiple linebreaks (actual line breaks) by one empty line:
        (\w+|\W+)\n\n+(\w+|\W+) replace by $1\n\n$2 
        And maybe "\s\s+" replace by " " (multiple spaces by 1 space)
    -->
    
    <!-- options for the apparatus variants footnotes -->
    <!-- Should we shorten the lemma in the footnote if the lemma has more than X words? 0 for no, other number for the max length of lemma in the note (in words) -->
    <xsl:param name="shortenLem">15</xsl:param>
    <!-- What word or phrase do you want to use in the critical notes to indicate that a variant is an omission? -->
    <xsl:param name="varOm">om.</xsl:param>
    <!-- What word or phrase do you want to use in the critical notes to indicate that a variant is an addition? -->
    <xsl:param name="varAdd">add.</xsl:param>
    
    
    <!-- the LaTeX code produced by this template was partly adapted from the examples in:
         https://ride.i-d-e.de/issues/issue-11/reledmac/
         https://github.com/MarjorieBurghart/TEI-CAT/blob/master/tei2latex_final.xslt
         https://www.overleaf.com/latex/examples/typesetting-scholarly-critical-editions-with-reledmac/vwfgrsxqncvv
    -->
    <xsl:template match="/">
        <xsl:text>
\documentclass[letterpaper,twoside]{article}
   
\usepackage[utf8]{inputenc}
\usepackage[english,latin]{babel}


%\DeclareUnicodeCharacter{2060}{\nolinebreak}
\usepackage{ebgaramond}
\usepackage{microtype} % improves justification

%---------------------------------------------------
\usepackage[innote]{indextools} % make the indices
\makeindex[title={Index Nominum},name=nominum]
\makeindex[title={Index Locorum},name=locorum]
        </xsl:text>
        <!-- the original CritApp template also includes a fancyhdr -->
        <!-- set up the reledmac package -->
        <xsl:text>
%---------------------------------------------------
% setup reledmac package
\usepackage[series={A,B},noend,nofamiliar,noeledsec,noledgroup]{reledmac} 
\Xarrangement[A]{paragraph}
\Xarrangement[B]{paragraph}
        
% set the space before each series of notes    
\Xbeforenotes[A]{2pt}
\Xbeforenotes[B]{2pt}

% Prevents the lemma from having the same characteristics as in the text (bold, italics, etc.)
\Xlemmadisablefontselection[A] 

% To print the line number in bold in the apparatus...
\Xnotenumfont{\normalfont\bfseries}

% Add different lemma separator?
%\Xlemmaseparator[]{\,--}   

% to number the lines; options can be: page, pstart or section
\lineation{page}

% setting lineation start and step
\setlength{\stanzaindentbase}{20pt}
\setstanzaindents{1,1}
\setcounter{stanzaindentsrepetition}{1}
\firstlinenum{0}
\linenumincrement{5} % 5 is default

% choose in which margin the line numbers will appear
\linenummargin{outer}
\Xnumberonlyfirstinline[] 
\Xnumberonlyfirstintwolines[]

% separator between entries on the same line
%\Xsymlinenum{} % leave empty if you don't want any

% order of the critical and familiar footnotes
\fnpos{critical-familiar}
        </xsl:text>

<!-- set document title, author and date -->
<xsl:text>
%---------------------------------------------------
\title{</xsl:text><xsl:value-of select="//t:title"/>
        <xsl:text>}
\author{</xsl:text><xsl:value-of select="//t:author"/>
        <xsl:text>}
\date{\today}
%---------------------------------------------------
            
        </xsl:text>
        <!-- TEIsection command adapted from the Critical App Toolbox -->
<xsl:text>
%---------------------------------------------------
    % Basic workaround for broken \section functionality in reledmac
    \makeatletter
    \newcommand{\TEIsection}[1]{\vspace{2em}
    \noindent{\centering\emph{#1}}\vspace{2em}}
    \par\nobreak\vspace{-\parskip}\@afterheading\noindent
    \makeatother
        </xsl:text>
        <!-- end TEIsection command -->

<xsl:text>           
%---------------------------------------------------
\begin{document} % start LaTeX document body

\maketitle % make the title
\tableofcontents % create a table of contents automatically

\newpage

        </xsl:text>
        <!-- TODO: get metadata from the header using the pull paradigm
            (like in the example below)
        z.B. recommended citation using the fancyhdr-package (TODO!) -->
<xsl:text>A list of personal names mentioned in the TEI header:</xsl:text>
<xsl:text>\begin{itemize}</xsl:text>
<xsl:for-each select="//t:persName[ancestor::t:teiHeader]">
    <xsl:text>\item </xsl:text>
    <xsl:value-of select="." />
    <xsl:text>
    
    </xsl:text>
</xsl:for-each>
<xsl:text>\end{itemize}
    
    Just playing around, basically. -- This is just for information purposes.
    Reuse this code as an example for how to get a LaTeX environment via XSL.
    Feel free to remove this!
    
\newpage
%---------------------------------------------------

</xsl:text>
     
        <!--  <xsl:apply-templates/> OR -->
        <xsl:apply-templates select="//t:text"/>
        <!-- so that only the body gets processed automatically by the push paradigm 
            (we already processed the header manually and thus, don't want this to be done again)
        Also, this stops the header from just being dumped unformatted into the document. -->
        
        
        <xsl:text>
            %---------------------------------------------------
            \end{document} % end LaTeX document body</xsl:text>
    </xsl:template>
    
    <xsl:template match="t:body">
        <!-- the TEI body is formatted as one reledmac paragraph -->
        <xsl:text>

%---------------------------------------------------
\section{Introduction}
Introductory text.

%---------------------------------------------------
\section{Edition}
% text outside \beginnumbering … \endnumbering works as normal LaTeX

%---------------------------------------------------
\beginnumbering % begins Reledmac numbered section
\pstart % begin a paragraph in Reledmac; or use the \autopar command

        </xsl:text>
        <xsl:apply-templates/>
        <xsl:text>
            
\pend % end a paragraph in Reledmac
\endnumbering % end Reledmac numbered section
%---------------------------------------------------

        </xsl:text>
        <!-- set up persons and places index (CritApp Toolbox) -->
        <xsl:text>
  \indexprologue{\small </xsl:text>
        <!-- if you want a prologue for the Index Nominum, add one here -->
        <xsl:text>} </xsl:text>
            <xsl:text>
  \printindex[nominum]</xsl:text>
        
                <xsl:text>
  \indexprologue{\small </xsl:text>
        <!-- if you want a prologue for the Index Locorum, add one here -->
        <xsl:text>} </xsl:text>
            <xsl:text>
  \printindex[locorum]</xsl:text>
    </xsl:template>
    
    <!-- Prints div heads as a Chapter (CritApp Toolbox) -->
    <xsl:template match="t:div">
        <xsl:apply-templates/>
    </xsl:template>
    
    
    <!-- Prints div heads (CritApp Toolbox) -->
    <xsl:template match="t:head[parent::t:div or parent::t:body]">
        <xsl:choose>
            <xsl:when test="not(ancestor::t:rdg)">
                <xsl:text>
      \pstart
      \TEIsection{</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <!-- If this is the descendant of a t:rdg, it will only appear in the critical footnotes, 
                    so paragraphs are not allowed here, and we don't want fancy markup either; 
                    just a space to separate paragraphs. -->
                <xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        
        <!-- several lemmata can end or begin at the same paragraph-like element; we're going to count the number of t:lem ancestors, and check for all of them is the current element is a first or last descendant -->
        <xsl:variable name="depthOfLem" select="count(ancestor::t:lem)"/>
        <xsl:call-template name="whileStartLem">
            <xsl:with-param name="depth">
                <xsl:value-of select="$depthOfLem"/>
            </xsl:with-param>
        </xsl:call-template>
        
        <xsl:apply-templates/>
        
        
        <!-- several lemmata can end or begin at the same paragraph-like element; we're going to count the number of t:lem ancestors, and check for all of them is the current element is a first or last descendant -->
        <xsl:call-template name="whileEndLem">
            <xsl:with-param name="depth">
                <xsl:value-of select="$depthOfLem"/>
            </xsl:with-param>
        </xsl:call-template>
        
        
        <xsl:if test="not(ancestor::t:rdg)">
            <!-- no paragraphs in the footnotes -->
            <xsl:text>}
    \pend
            
            </xsl:text>
        </xsl:if>
    </xsl:template>
    
    
    <!-- needed for the CritApp Toolbox stuff (students ignore this) -->
    <xsl:template name="whileStartLem">
        <xsl:param name="depth"/>
        <xsl:if test="$depth > 0">
            <xsl:if
                test="ancestor::t:lem[position() = $depth]/descendant::node()[name() = 'p' or name() = 'head' or name() = 'lg' or name() = 'list'][position() = 1] = self::node()">
                <xsl:text>\edlabel{lem_</xsl:text>
                <xsl:number select="ancestor::t:lem[position() = $depth]" level="any"/>
                <xsl:text>_start}</xsl:text>
            </xsl:if>
            <xsl:call-template name="whileStartLem">
                <xsl:with-param name="depth" select="$depth - 1"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- print div heads when appropriate structure isn't there -->
    <xsl:template match="t:head[ancestor::t:div]">
        <xsl:text>
\TEIsection{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>} 
        
        </xsl:text>
    </xsl:template>
    
    <!-- needed for the CritApp Toolbox stuff (students ignore this) -->
    <xsl:template name="whileEndLem">
        <xsl:param name="depth"/>
        <xsl:if test="$depth > 0">
            <xsl:if
                test="ancestor::t:lem[position() = $depth]/descendant::node()[name() = 'p' or name() = 'head' or name() = 'lg' or name() = 'list'][last()] = self::node()">
                <xsl:text>\edtext{</xsl:text>
                <xsl:text>\edlabel{lem_</xsl:text>
                <xsl:number select="ancestor::t:lem[position() = $depth]" level="any"/>
                <xsl:text>_end}}</xsl:text>
                <xsl:text>{\xxref{lem_</xsl:text>
                <xsl:number select="ancestor::t:lem[position() = $depth]" level="any"/>
                <xsl:text>_start}{lem_</xsl:text>
                <xsl:number select="ancestor::t:lem[position() = $depth]" level="any"/>
                <xsl:text>_end}</xsl:text>
                <!-- SL: call-template noteForLemmaWithParagraphs removed here for simplification -->
                <xsl:text>}</xsl:text>
            </xsl:if>
            <xsl:call-template name="whileEndLem">
                <xsl:with-param name="depth" select="$depth - 1"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="t:p">
        <xsl:apply-templates/>
        <xsl:text>
            
        </xsl:text>
    </xsl:template>

    
    <!-- Add index entries for person names (CritApp Toolbox) -->
    <xsl:template match="t:persName">
                <xsl:choose>
                    <xsl:when test="@key">
                        <xsl:apply-templates/>
                        <xsl:text>\index[nominum]{</xsl:text>
                        <xsl:value-of select="@key"/>
                        <xsl:text>} </xsl:text>
                    </xsl:when>
                    <xsl:when test="@ref">
                        <xsl:variable name="nameRef">
                            <xsl:value-of select="translate(@ref, '#', '')"/>
                        </xsl:variable>
                        <xsl:apply-templates/>
                        <xsl:text>\index[nominum]{</xsl:text>
                        <xsl:value-of select="//t:person[@xml:id = $nameRef]/t:persName"/>
                        <xsl:text>} </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
    </xsl:template>
    
    
    <!-- Add index entries for place names (CritApp Toolbox) -->
    <xsl:template match="t:placeName">
                <xsl:choose>
                    <xsl:when test="@key">
                        <xsl:apply-templates/>\index[locorum]{<xsl:value-of select="@key"/>} </xsl:when>
                    <xsl:when test="@ref">
                        <xsl:variable name="nameRef"><xsl:value-of select="translate(@ref, '#', '')"
                        /></xsl:variable>
                        <xsl:apply-templates/>\index[locorum]{<xsl:value-of
                            select="//t:place[@xml:id = $nameRef]/t:placeName"/>} </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>     
    </xsl:template>
    
    <!--Adds linebreaks into document-->
    <xsl:template match="t:lb"/>
    
    
    <!-- adds page breaks into document (CritApp Toolbox) -->
    <xsl:template match="t:pb">
                    <!-- Printing all t:pb and MS sigillum -->
                    \ledsidenote{<xsl:if test="@ed|@edRef">\emph{<xsl:choose>
                            <xsl:when test="@ed and @edRef"><xsl:value-of select="translate(@edRef, '#', '')"
                            /></xsl:when>
                            <xsl:when test="@ed and not(@edRef)"><xsl:value-of select="translate(@ed, '#', '')"
                            /></xsl:when>
                            <xsl:when test="@edRef and not(@ed)"><xsl:value-of
                                select="translate(@edRef, '#', '')"/></xsl:when>
                        </xsl:choose><xsl:text> </xsl:text>}</xsl:if><xsl:value-of select="@n"/>}         
    </xsl:template>
    
    
    <!-- textual apparatus (CritApp Toolbox) 
         sigla of witnesses displayed in italic -->
  <xsl:template match="t:app">
    <xsl:variable name="currentLemma">
      <xsl:apply-templates select="./t:lem"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when
        test="not(descendant::t:p) and not(descendant::t:head) and not(descendant::t:lg) and not(descendant::t:list)">
        <xsl:choose>
          <!-- default case -->
          <!-- It is common practice to write the apparatus text in lower case, so I use the \MakeLowercase{} command  -->
          <!-- Common case: there is a <lem> -->
          <xsl:when test="./t:lem/descendant-or-self::text() != ''">
            <xsl:choose>
              <!-- If there is a t:note[@type='altLem'], then we use its contents for the lemma, without changing the case -->
              <xsl:when test="./t:note[@type='altLem']">
                <xsl:text>\edtext{</xsl:text>
                <xsl:value-of select="$currentLemma"/>
                <xsl:text>}{\lemma{</xsl:text>
                <xsl:apply-templates select="./t:note[@type='altLem']"/>
                <xsl:text>} </xsl:text>
                <xsl:choose>
                  <xsl:when test="./t:rdg">
                    <xsl:text>\Afootnote{</xsl:text>
                    <xsl:for-each select="./t:rdg">
                      <xsl:variable name="currentRdg">
                        <xsl:apply-templates select="."/>
                      </xsl:variable>
                      <xsl:choose>
                        <xsl:when test="descendant-or-self::text() != ''">
                          <!-- doing this because of a bug in reledmac when a  footnote starts with plus or minus-->
                          <xsl:if
                            test="starts-with($currentRdg, 'plus') or starts-with($currentRdg, 'minus')">
                            <xsl:text>\,</xsl:text>
                          </xsl:if>
                          <xsl:value-of select="lower-case($currentRdg)"/>
                              <xsl:text> \emph{</xsl:text>
                              <xsl:text> </xsl:text>

                          <xsl:value-of select="translate(@wit, '#', '')"/>
                          <xsl:text>}</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:text>\emph{</xsl:text>
                          <xsl:value-of select="$varOm"/>
                          <xsl:text>} </xsl:text>
                          <xsl:text>\emph{</xsl:text>
                          <xsl:value-of select="translate(@wit, '#', '')"/>
                          <xsl:text>}</xsl:text>
                        </xsl:otherwise>
                      </xsl:choose>
                      <xsl:if test="following-sibling::node()/name() = 'rdg'">
                        <xsl:text>, </xsl:text>
                      </xsl:if>                               
                    </xsl:for-each>
                    <xsl:text>}}</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <!-- Eh??  -->
                    <xsl:text>\Afootnote{</xsl:text>
                    <xsl:apply-templates/>
                    <xsl:text>}}</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <!-- If there is not, we use the contents of the <lem> -->
              <xsl:otherwise>
                <xsl:text>\edtext{</xsl:text>
                <xsl:value-of select="$currentLemma"/>
                <xsl:text>}{\lemma{</xsl:text>
                <xsl:variable name="currentLemmaNote"
                  select="./t:lem/tokenize(normalize-space(string-join(descendant-or-self::text()[not(parent::t:rdg)][not(ancestor::t:note)][not(ancestor::t:bibl)],'')),' ')"/>

                <xsl:choose>
                  <xsl:when test="$shortenLem != '0' and count($currentLemmaNote) > $shortenLem">
                    <xsl:value-of
                      select="translate(lower-case($currentLemmaNote[position() = 1]), ',.!?:;)', '')"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of
                      select="translate(lower-case($currentLemmaNote[position() = 2]), ',.!?:;)', '')"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of
                      select="translate(lower-case($currentLemmaNote[position() = 3]), ',.!?:;)', '')"/>
                    <xsl:text> \ldots{} </xsl:text>
                    <xsl:value-of
                      select="translate(lower-case($currentLemmaNote[last() - 2]), ',.!?:;)', '')"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of
                      select="translate(lower-case($currentLemmaNote[last() - 1]), ',.!?:;)', '')"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of
                      select="translate(lower-case($currentLemmaNote[last()]), ',.!?:;)', '')"/>
                    <!--                <xsl:value-of select="translate(lower-case(./t:lem/tokenize(normalize-space(string-join(descendant-or-self::text()[not(ancestor::t:rdg)][not(ancestor::t:note)][not(ancestor::t:bibl)],'')),' ')[last()]), ',.!?:;)', '')"/>   -->
                  </xsl:when>
                  <!-- we must not use $currentLemma here; it's for the edtext and has plenty of unnecessary tex markup (especially if the apps are nested)
              ==> write a clean version of the lemma, text only (could be optimised) -->
                  <xsl:otherwise>
                    <xsl:value-of
                      select="translate(lower-case(./t:lem/normalize-space(string-join(descendant-or-self::text()[not(parent::t:rdg)][not(ancestor::t:note)][not(ancestor::t:bibl)],''))), ',.!?:;)', '')"
                    />
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:text>} </xsl:text>
                <xsl:choose>
                  <xsl:when test="./t:rdg">
                    <xsl:text>\Afootnote{</xsl:text>
                    <xsl:for-each select="./t:rdg">
                      <xsl:variable name="currentRdg">
                        <xsl:apply-templates select="."/>
                      </xsl:variable>
                      <xsl:choose>
                        <xsl:when test="descendant-or-self::text() != ''">
                          <xsl:if
                            test="starts-with($currentRdg, 'plus') or starts-with($currentRdg, 'minus')">
                            <xsl:text>\,</xsl:text>
                          </xsl:if>
                          <xsl:value-of select="lower-case($currentRdg)"/>
                            <xsl:text> \emph{</xsl:text>                     
                          <xsl:value-of select="translate(@wit, '#', '')"/>
                          <xsl:text>}</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                          <!-- it is an omission by this witness -->
                          <xsl:text>\emph{</xsl:text>
                          <xsl:value-of select="$varOm"/>
                          <xsl:text>} </xsl:text>
                          <xsl:text>\emph{</xsl:text>
                          <xsl:value-of select="translate(@wit, '#', '')"/>
                          <xsl:text>}</xsl:text>
                        </xsl:otherwise>
                      </xsl:choose>
                      <xsl:if test="following-sibling::node()/name() = 'rdg'">
                        <xsl:text>, </xsl:text>
                      </xsl:if>                      
                      <!-- Lame attenpt at correctly displaying the notes. TODO: do betetr -->
                      <!--
                      <xsl:apply-templates select="following-sibling::t:note"/>                      
                      -->
                    </xsl:for-each>
                    <xsl:text>}}</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <!-- Eh??  -->
                    <xsl:text>\Afootnote{</xsl:text>
                    <xsl:apply-templates/>
                    <xsl:text>}}</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <!-- addition; the lemma is empty, so short of a better thing we need to put in the footnote's lemma the last word preceding this <app> -->
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="./t:note[@type='altLem']">
                <xsl:text>\edtext{</xsl:text>
                <xsl:value-of select="$currentLemma"/>
                <xsl:text>}{\lemma{</xsl:text>
                <xsl:apply-templates select="./t:note[@type='altLem']"/>
                <xsl:text>} </xsl:text>
                <xsl:choose>
                  <xsl:when test="./t:rdg">
                    <xsl:text>\Afootnote{</xsl:text>
                    <xsl:for-each select="./t:rdg">
                      <xsl:variable name="currentRdg">
                        <xsl:apply-templates select="."/>
                      </xsl:variable>
                      <xsl:if test="descendant-or-self::text() != ''">
                        <xsl:if
                          test="starts-with($currentRdg, 'plus') or starts-with($currentRdg, 'minus')">
                          <xsl:text>\,</xsl:text>
                        </xsl:if>
                        <xsl:value-of select="lower-case($currentRdg)"/>
                        <xsl:text> \emph{</xsl:text>
                        <xsl:value-of select="$varAdd"/>
                        <xsl:text>} </xsl:text>
                        <xsl:text>\emph{</xsl:text>
                        <xsl:value-of select="translate(@wit, '#', '')"/>
                        <xsl:text>}</xsl:text>
                        <xsl:if
                          test="following-sibling::node()/name() = 'rdg' and following-sibling::node()/descendant-or-self::text() != ''">
                          <xsl:text>, </xsl:text>
                        </xsl:if>
                      </xsl:if>
                    </xsl:for-each>
                    <xsl:text>}}</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <!-- Eh??  -->
                    <xsl:text>\Afootnote{</xsl:text>
                    <xsl:apply-templates/>
                    <xsl:text>}}</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>\edtext{}{\lemma{</xsl:text>
                <xsl:variable name="currenttPreviousWord">
                  <xsl:value-of
                    select="tokenize(normalize-space(string-join(preceding::text()[not(ancestor::t:rdg)][not(ancestor::t:note)][not(ancestor::t:bibl)],'')),' ')[last()]"
                  />
                </xsl:variable>
                <!-- If the "word" immediately preceding the addition is a punctuation mark, then we're going to select the "word" before this one; 
            TODO: ideally, this should be recursive -->
                <xsl:choose>
                  <xsl:when
                    test="$currenttPreviousWord = '.' or $currenttPreviousWord = '!' or $currenttPreviousWord = '?' or $currenttPreviousWord = ';' or $currenttPreviousWord = ':' or $currenttPreviousWord = ','">
                    <xsl:value-of
                      select="translate(lower-case(tokenize(normalize-space(string-join(preceding::text()[not(ancestor::t:rdg)][not(ancestor::t:note)][not(ancestor::t:bibl)],'')),' ')[last()-1]), ',.!?:;)', '')"
                    />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of
                      select="translate(lower-case(tokenize(normalize-space(string-join(preceding::text()[not(ancestor::t:rdg)][not(ancestor::t:note)][not(ancestor::t:bibl)],'')),' ')[last()]), ',.!?:;)', '')"
                    />
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:text>} </xsl:text>
                <xsl:choose>
                  <xsl:when test="./t:rdg">
                    <xsl:text>\Afootnote{</xsl:text>
                    <xsl:for-each select="./t:rdg">
                      <xsl:variable name="currentRdg">
                        <xsl:apply-templates select="."/>
                      </xsl:variable>
                      <xsl:if test="descendant-or-self::text() != ''">
                        <xsl:if
                          test="starts-with($currentRdg, 'plus') or starts-with($currentRdg, 'minus')">
                          <xsl:text>\,</xsl:text>
                        </xsl:if>
                        <xsl:value-of select="lower-case($currentRdg)"/>
                        <xsl:text> \emph{</xsl:text>
                        <xsl:value-of select="$varAdd"/>
                        <xsl:text>} </xsl:text>
                        <xsl:text>\emph{</xsl:text>
                        <xsl:value-of select="translate(@wit, '#', '')"/>
                        <xsl:text>}</xsl:text>
                        <xsl:if
                          test="following-sibling::node()/name() = 'rdg' and following-sibling::node()/descendant-or-self::text() != ''">
                          <xsl:text>, </xsl:text>
                        </xsl:if>
                      </xsl:if>
                    </xsl:for-each>
                    <xsl:text>}}</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <!-- Eh??  -->
                    <xsl:text>\Afootnote{</xsl:text>
                    <xsl:apply-templates/>
                    <xsl:text>}}</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="t:lem"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>


    <!-- Prints all t:note[@type='footnote'] as footnotes 
         if you want them as \Afootnote, you need to make sure
         they end up inside and \edtext first and then modify this -->
  <xsl:template match="t:note[@type='footnote']">
      <xsl:text>\footnote</xsl:text>
      <xsl:if test="matches(@n,'[0-9]+')">
          <xsl:text>[</xsl:text><xsl:value-of select="@n"/><xsl:text>]</xsl:text>
      </xsl:if>
      <xsl:text>{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>} </xsl:text>
  </xsl:template>


  <xsl:template match="t:note[ancestor::t:app][@type != 'altLem']">
    <xsl:text>\emph{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>} </xsl:text>
  </xsl:template>

    <!-- we use the @next and @prev to join split citations (CritApp Toolbox) -->

  <xsl:template match="t:cit">
    <xsl:choose>
      <xsl:when test="./t:quote//t:lg">
        <!-- the complicated case of lg...Not very good! TODO: do better -->
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="@next">
            <xsl:choose>
              <xsl:when test="@type='bible'">
                <xsl:text>\emph{</xsl:text>
                <xsl:apply-templates select="t:quote"/>
                <xsl:text>}</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>\edlabel{</xsl:text>
                <xsl:value-of select="translate(@xml:id, '#', '')"/>
                <xsl:text>}</xsl:text>
                <xsl:apply-templates select="t:quote"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="@prev">
            <xsl:choose>
              <xsl:when test="@type='bible'">
                <xsl:text>\emph{</xsl:text>
                <xsl:apply-templates select="t:quote"/>
                <xsl:text>}</xsl:text>
                <xsl:apply-templates select="t:bibl" mode="bibl"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>\edtext{</xsl:text>
                <xsl:apply-templates select="t:quote"/>
                <xsl:text>\edlabel{</xsl:text>
                <xsl:value-of select="translate(@xml:id, '#', '')"/>
                <xsl:text>}}{\xxref{</xsl:text>
                <xsl:value-of select="translate(@prev, '#', '')"/>
                <xsl:text>}{</xsl:text>
                <xsl:value-of select="translate(@xml:id, '#', '')"/>
                <xsl:text>}\lemma{}{\Bfootnote[nosep]{</xsl:text>
                <xsl:apply-templates select="t:bibl" mode="src"/>
                <xsl:text>}}}</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="@type='bible'">
                <xsl:text>\emph{</xsl:text>
                <xsl:apply-templates select="t:quote"/>
                <xsl:text>}</xsl:text>
                <xsl:apply-templates select="t:bibl" mode="bibl"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>\edtext{</xsl:text>
                <xsl:apply-templates select="t:quote"/>
                <xsl:text>}{\lemma{}{\Bfootnote[nosep]{</xsl:text>
                <xsl:apply-templates select="t:bibl" mode="src"/>
                <xsl:text>}}}</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>
    
    
    <!-- process quotes (CritApp Toolbox) 
         not italicized, with the following start/end quotation marks -->
  <xsl:template match="t:quote">
      <xsl:text>``</xsl:text>
    <xsl:apply-templates/>
      <xsl:text>''</xsl:text>
  </xsl:template>
    
    
    <!-- process bibl (CritApp Toolbox) -->
  <xsl:template match="t:bibl" mode="bibl">
    <xsl:text> ⟨</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>⟩</xsl:text>
  </xsl:template>
  <xsl:template match="t:bibl" mode="src">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="t:bibl"/>

  <xsl:template match="t:title">
    <xsl:text>\emph{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>
    
    <!-- hi elements (CritApp Toolbox) -->
    <xsl:template match="t:hi">
        <xsl:choose>
            <xsl:when test="@rend = 'italic' or @rend='italics'">
                <xsl:text> \emph{</xsl:text>
                <xsl:apply-templates/>
                <xsl:text>} </xsl:text>
            </xsl:when>
            <xsl:when test="@rend = 'bold'">
                <xsl:text> \textbf{</xsl:text>
                <xsl:apply-templates/>
                <xsl:text>} </xsl:text>
            </xsl:when>
            <xsl:when test="@rend = 'sup'">
                <xsl:text> \textsuperscript{</xsl:text>
                <xsl:apply-templates/>
                <xsl:text>} </xsl:text>
            </xsl:when>      
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="t:ref"> \textsuperscript{ <xsl:apply-templates/>} </xsl:template>
    
    <!-- subst (CritApp Toolbox) -->
    <xsl:template match="t:subst">
        <xsl:text> \emph{subst.:} </xsl:text>
        <xsl:apply-templates select="t:del"/><xsl:text> \emph{del.,} </xsl:text>
        <xsl:apply-templates select="t:add"/><xsl:text> \emph{add.} </xsl:text>    
    </xsl:template>
    
    <!-- witness list (CritApp Toolbox) -->
    <xsl:template match="t:listWit">
        <xsl:text>
      \begin{description}</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>
      \end{description}</xsl:text>
    </xsl:template>
    <xsl:template match="t:witness">
        <xsl:text>
      \item[</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>]
    </xsl:text>
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- check which XML entities and other glyphs appear in the source XML,
         they might all have to be replaced ("escaped") for LaTeX like the following -->
    <xsl:template match="text()">
        <xsl:variable name="chars_to_add_backslash" select="'}{_$%#'"/>
        <xsl:variable name="lbrack" select="'\['"/>
        <xsl:variable name="rbrack" select="'\]'"/>
        <xsl:analyze-string select="." regex="([&amp;])|([{$chars_to_add_backslash}])|([&gt;])|([&lt;])|([¶])|([{$lbrack}])|([{$rbrack}])">
            <xsl:matching-substring>
                <xsl:choose>
                    <xsl:when test="regex-group(1)">
                        <xsl:text>\&amp;</xsl:text>
                    </xsl:when>
                    <xsl:when test="regex-group(2)">
                        <xsl:text>\</xsl:text><xsl:value-of select="regex-group(2)"/>
                    </xsl:when>
                    <xsl:when test="regex-group(3)">
                        <xsl:text>⟩</xsl:text>
                    </xsl:when>
                    <xsl:when test="regex-group(4)">
                        <xsl:text>⟨</xsl:text>
                    </xsl:when>
                    <xsl:when test="regex-group(5)">
                        <xsl:text>\P{}</xsl:text>
                    </xsl:when>
                    <xsl:when test="regex-group(6)">
                        <xsl:text>\lbrack{}</xsl:text>
                    </xsl:when>
                    <xsl:when test="regex-group(7)">
                        <xsl:text>\rbrack{}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <!-- SL: I added normalize space here -->
                <xsl:value-of select="normalize-space(.)" />
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <!-- instead of the code above, it would also work like this
     <xsl:template match="text()">
     <xsl:value-of select="translate(., '&#xA0;', ' ')"/>
 </xsl:template>
    -->
</xsl:stylesheet>