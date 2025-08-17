;; easycrypt.eld
;; Tempel templates for easycrypt mode
;; Doesn't include possibilities that are too close to single keywords
;; (as these should be covered by another mechanism)

easycrypt-mode

;;; Comments and documentation
(com "(* " q " *)"
     :doc
     "Regular, non-documentation comment on a single line.")

(comn "(*" n>
      q n
      "*)" >
      :doc
      "Regular, non-documentation comment with newline(s), putting the opener
and closer on separate lines.")

(docc "(*& " q " &*)"
      :doc
      "Item documentation comment on a single line.

An item documentation comment is `linked' to the next item in the file, serving
as (part of) its documentation. For example, this will show up alongside the
`linked' item in the generated documentation for this file.")

(docn "(*&" n>
      q n
      "&*)" >
      :doc
      "Item documentation comment with newline(s), putting the opener and closer
on separate lines.

See the `docc' template for more information on documentation comments.")

(docf "(*^" n>
      (file-name-nondirectory (or (buffer-file-name) (buffer-name))) n
      n>
      "- Author: " p n>
      "- Date: " (p (format-time-string "%Y-%m-%d")) n
      n>
      "Description:" n>
      q n
      "^*)" >
      :doc
      "File documentation comment, automatically inserting the name of the
currently visited file as `header' (first line), as well as an author, date, and
description field. The date field is initially filled with the current date.

A file documentation comment is `linked' to the current file, serving as (part
of) its documentation; typically, this is used for relevant meta information of
the file and/or an introduction or overview of the file's purpose and content.
This will, e.g., show up at the top of the generated documentation for this
file.")


;;; Meta
(req "require " q "."
     :doc
     "Loads specified EasyCrypt files into the current context.

The names of the specified should be given as a space-separated list,
without (file) extensions. It is allowed to have multiple `require' commands
throughout a script/session, so it is not mandatory to specify all files at
once.

Provided files must be present in the load path (of the current EasyCrypt
session).

Example:
require AllCore List.
require Distr.")

(imp "import " q "."
     :doc
     "Loads specified (theory) namespaces into the current context.

Loading a namespace enables direct referencing to items from that
namespace (i.e., without explicitly specifying the namespace).

The theories for which to load the namespaces should be given as a
space-separated list. It is allowed to have multiple `import' commands
throughout a script/session, so it is not mandatory to specify all theories at
once.

Provided theories must be present into the current context, which can be achieved
by using `require' on the files containing the theories (see the `req' template
for more information).

Example:
import AllCore.
import List Distr.")

(reqimp "require import " q "."
        :doc
        "Loads specified EasyCrypt files and corresponding namespaces into the
current context.

Essentially syntactic sugar for a `require' statement followed by an `import'
statement with the same arguments.

See the `req' and `imp' templates for more information on `require' and
`import'.

Example:
require import AllCore List Distr.")

(froreq "from " p " require " q
        :doc
        "Loads EasyCrypt files (given to `require') from the library (given to
`from') into the current context.

The specified library must be in the current load path,
typically added via an EasyCrypt project file or the `-I' command line option.

See the `req' template for more information on `require'.

Example:
from Jasmin require JModel JArray.")

(froreqimp "from " p " require import " q
           :doc
           "Loads EasyCrypt files and corresponding namespaces (given to `require
import') from the library (given to `from') into the current context.

Essentially syntactic sugar for a `from require' statement followed by an
`import' statement with the same arguments.

See the `froreq' and `imp' templates for more information on
`from require' and `import'.

Example:
from Jasmin require import JModel JArray.")

(clo "clone " q "."
     :doc
     "Creates an instance of the specified theory in the current context.

Instantiating a (potentially abstract) theory and its components through cloning
allows for the reuse of definitions/results from the theory in different
context, facilitating modularity.

Only a single theory can be cloned at a time.

The provided theory must be present in the current context, which can be achieved
by using `require' on the files containing the theories (see the `req' template
for more information).

See the other templates starting with `clo' for more information on
the cloning mechanism and its features. Particularly,
see `cloas', `clowi', `cloimp', and `cloinc'.

Example:
clone KeyedHashFunctions.")

(cloas "clone " p " as " q "."
       :doc
       "Creates an instance of the theory (given to `clone')
under the name (given to `as') in the current context.

The specified name should be a valid theory name not yet used in
the current context.

See the `clo' template for more information on `clone'.

Example:
clone KeyedHashFunctions as KHFs.")

(clowi "clone " p " with" n>
       q "."
       :doc
       "Creates an instance of the theory (given to `clone') in the current context
with some of its items instantiated using items from the current context
(as specified by the argument of `with').

The argument of `with' should be a comma-separated list
(whitespace is allowed but ignored) with entries of the form
`<itemkind> <origitemname> <inst> <newitemname>':
- `<itemkind>' is the kind of the item to instantiate, e.g., `type', `op'.
- `<origitemname>' is the name of the item to instantiate.
- `<inst>' is the type of instantiation, which may be one of
  `<-', `<=', or `='. The first fully replaces every reference to the
  original item from the cloned theory, removing the original definition;
  the second fully replaces every reference to the original item from the
  cloned theory, changing the original definition to be an equality with the
  new item; the third keeps every reference to the original item from the
  cloned theory, only changing the original definition to be
  an equality with the new item.
- `<newitemname>' is the name of the item from the current context
  to instantiate the original item from the cloned theory with.

The list should be terminated with a period (`.').

When you instantiate abstract items that have axiomatized properties in the
cloned theory, you probably (should) want to prove these axioms actually hold
for the concrete items you used to instantiate them. This can be achieved by
using the special keyword `proof' as the final entry. There should be no comma
between the last actual (instantiation) entry and `proof'. As argument, this
keyword takes a comma-separated list of axioms to prove. To prove every axiom,
pass `*' as argument, i.e., `proof *'.

See the `clo' template for more information on `clone'.

Example:
clone KeyedHashFunctions with
  type key_t <- keys,
  type in_t <- input,
  type out_t <- output,
  op f <- hashfun

  proof *.")


(cloaswi "clone " p " as " p " with" n>
         q "."
         :doc
         "Creates an instance of the theory (given to `clone') under the name
(given to `as') in the current context with some of its items instantiated using
items from the current context (as specified by the argument of `with').

See the `clo', `cloas', and `clowi' templates for more information on
`clone' and its `as'/`with' features.

Example:
clone KeyedHashFunctions as KHFs with
  type key_t <- keys,
  type in_t <- input,
  type out_t <- output,
  op f <- hashfun

  proof *.")

(cloimp "clone import " q "."
        :doc
        "Creates an instance of the theory (given to `clone import') and loads
the corresponding namespace in the current context.

Essentially syntactic sugar for a `clone' statement followed by an `import'
statement with the same theory argument.

See the `clo' and `imp' templates for more information on `clone' and
`import'.

Example:
clone import KeyedHashFunctions.")

(cloimpas "clone import " p " as " q "."
          :doc
          "Creates an instance of the theory (given to `clone import') under the
name (given to `as') and loads the corresponding namespace in the current
context.

Essentially syntactic sugar for a `clone as' statement followed by an `import'
statement with the specified name (given to `as') as argument.

See the `cloas' and `imp' templates for more information on `clone as' and
`import'.

Example:
clone import KeyedHashFunctions as KHFs.")

(cloimpwi "clone import " p " with" n>
          q "."
          :doc
          "Creates an instance of the theory (given to `clone import') with some
of its items instantiated using items from the current context (as specified by
the argument of `with') and loads the corresponding namespace in the current
context.

Essentially syntactic sugar for a `clone with' statement followed by an `import'
statement with the same theory argument.

See the `clowi' and `imp' templates for more information on `clone with' and
`import'.

Example:
clone import KeyedHashFunctions with
  type key_t <- keys,
  type in_t <- input,
  type out_t <- output,
  op f <- hashfun

  proof *.")

(cloimpaswi "clone import " p " as " p " with" n>
            q "."
            :doc
            "Creates an instance of the theory (given to `clone import') under
the name (given to `as') with some of its items instantiated using items from
the current context (as specified by the argument of `with') and loads the
corresponding namespace in the current context.

Essentially syntactic sugar for a `clone as with' statement followed by an
`import' statement with the specified name (given to `as') as argument.

See the `cloaswi' and `imp' templates for more information on `clone as with'
and `import'.

Example:
clone import KeyedHashFunctions as KHFs with
  type key_t <- keys,
  type in_t <- input,
  type out_t <- output,
  op f <- hashfun

  proof *.")

(cloinc "clone include " q "."
        :doc
        "Creates an instance of the specified theory and includes it in the
current context as if the code of the resulting instance was inserted literally.

Certain statements do not have the same effect as they would have if the
statements were inserted literally, particularly \"meta-statements\" like
`import'.

See the `clo' template for more information on `clone'.

Example:
clone include KeyedHashFunctions.")

(cloincas "clone include " p " as " q "."
          :doc
          "Creates an instance of the theory (given to `clone include') under
the name (given to `as') and includes it in the current context as if the code
of the resulting instance was inserted literally.

See the `cloinc' and `cloas' templates for more information on `clone include'
and the `as' feature.

clone include KeyedHashFunctions as KHFs.")

(cloincwi "clone include " p " with" n>
          q "."
          :doc
          "Creates an instance of the theory (given to `clone include') with
some of its items instantiated using items from the current context (as
specified by the argument of `with') and includes it in the current context as
if the code of the resulting instance was inserted literally.

See the `cloinc' and `clowi' templates for more information on `clone include'
and the `with' feature.

Example:
clone include KeyedHashFunctions with
  type key_t <- keys,
  type in_t <- input,
  type out_t <- output,
  op f <- hashfun

  proof *.")

(cloincaswi "clone include " p " as " p " with" n>
            q "."
            :doc
            "Creates an instance of the theory (given to `clone inclue') under
the name (given to `as') with some of its items instantiated using items from
the current context (as specified by the argument to `with') and includes it in
the current context as if the code of the resulting instance was inserted
literally.

See the `cloinc', `cloas', and `clowi' templates for more information
on `clone include' and the `as/with' feature.

Example:
clone include KeyedHashFunctions as KHFs with
  type key_t <- keys,
  type in_t <- input,
  type out_t <- output,
  op f <- hashfun

  proof *.")

(hinsim "hint simplify " q
        :doc
        "Adds the specified axioms/lemmas as hints for the `simplify' tactic.

Example:
hint simplify oget_some, oget_none.")

(hinrew "hint rewrite " p " : " q
        :doc
        "Adds the specified axioms/lemmas as hints for the `rewrite' tactic.")
(hinex "hint exact " p " : " q
       :doc
       "Adds axioms/lemmas as hints for the `exact' tactic.")


;; Functional specification
(type "type " p " = " q ".")
(typen "type " p " =" n>
       q "." >)

(op "op " p " : " p " = " q ".")
(opn "op " p " : " p " =" n>
     q "." >)
(opas "op " p " : { " p " | " p " } as " q ".")


(const "const " p " : " p " = " q ".")
(constn "const " p " : " p " =" n>
        q "." >)

(abbrev "abbrev " p " = " q ".")
(abbrevt "abbrev " p " : " p " = " q ".")
(abbrevn "abbrev " p " =" n>
         q "." >)

(theory "theory " (p "" thid)  "." n>
        q n>
        "end " (s thid) "." >)
(abstracttheory "abstract " (i theory))

(section "section." n>
         q >
         "end section." >)
(sectionid "section" (p "" secid) "." n>
           q >
           "end section " (s secid) "." >)

(declaremodule "declare module " p " <: " p "{ " q " }.")
(declaremodulenm "declare module " p " <: " q ".")

(Pr "Pr[" p " @ " p " : " q "]")
(Prn "Pr[" n>
      p " @ " p " :" n>
      q "]" >)
(Prm "Pr[" p " @ &m : " q "]")
(Prmr "Pr[" q " @ &m : res]")

(hoare "hoare[" p " : " p " ==> " q "]")
(hoaren "hoare[" n>
         p " :" n>
         p n>
         "==>" n>
         q n>
         "]" >)

(phoare "phoare[" p " : " p " ==> " p "] = " q)
(phoaren "phoare[" n>
          p " :" n>
          p n>
          "==>" n>
          p n>
          "] = " q >)
(phoare1 "phoare[" p " : " p " ==> " q "] = 1%r")
(phoare1n "phoare[" n>
           p " :" n>
           p n>
           "==>" n>
           q n>
           "] = 1%r" >)

(equiv "equiv[" p " ~ " p " : " p " ==> " q "]")
(equivn "equiv[" n>
        p " ~ " p ":" n>
        p n>
        "==>" n>
        q n>
        "]" >)

(ehoare "ehoare[" p " : " p " ==> " q "]")
(ehoaren "ehoare[" n>
         p " :" n>
         p n>
         "==>" n>
         q n>
         "]" >)

(axiom "axiom " p " : " q ".")
(axiomn "axiom " p " :" n>
        q "." >)

(proof "proof." > n>
       q n>
       "qed." >)
(proofpq "proof." q "qed." >)

(lemma "lemma " p " : " p "." n>
       (i proof))
(lemmaby "lemma " p " : " p " by " q ".")
(lemmapq "lemma " p " : " p "." n>
         (i proofpq) >)
(lemman "lemma " p " :" n>
        p "." n>
        (i proof))
(lemmanpq "lemma " p " :" n>
          p "." n>
          (i proofpq))

(lemmall "lemma " p " : islossless " p "." n>
         (i proof))
(lemmallpq "lemma " p " : islossless " p "." n>
           (i proofpq))

(hoarelemma "hoare " p " : " p " : " p " ==> " p "." n>
             (i proof))
(hoarelemmapq "hoare " p " : " p " : " p " ==> " p "." n>
              (i proofpq))
(hoarelemman "hoare " p " :" n>
             p " : " p " ==> " p "." n>
             (i proof))
(hoarenlemman "hoare " p " :" n>
              p " :" n>
              p n>
              "==>" n>
              p "." n>
              (i proof))

(equivlemma "equiv " p " : " p " ~ " p " : " p " ==> "p "." n>
            (i proof))
(equivlemmapq "equiv " p " : " p " ~ " p " : " p " ==> "p "." n>
              (i proofpq))
(equivlemman "equiv " p " :" n>
             p " ~ " p " : " p " ==> "p "." n>
             (i proof))
(equivnlemman "equiv " p " :" n>
               p " ~ " p " :" n>
               p n>
               "==>" n>
               p "." n>
               (i proof))

(ehoarelemma "ehoare " p " : " p " : " p " ==> " p "." n>
             (i proof))
(ehoarelemmapq "ehoare " p " : " p " : " p " ==> " p "." n>
               (i proofpq))
(ehoarelemman "ehoare " p " :" n>
              p " : " p " ==> " p "." n>
              (i proof))
(ehoarenlemman "ehoare " p " :" n>
               p " :" n>
               p n>
               "==>" n>
               p "." n>
               (i proof))

(fun "fun (" p ") => " q)
(funn "fun (" p ") =>" n>
      q)
(forall "forall (" p "), " q)
(foralln "forall (" p ")," n>
         q)
(exists "exists (" p "), " q)
(existsn "exists (" p ")," n>
         q)
(ifthenelse "if " p " then " p " else " q)
(ifthenelsen "if " p n>
             "then " p n>
             "else " q)
(ge0 "0 <= " q)
(gt0 "0 < " q)
(rngin p " <= " p " <= " q)
(rngex p " < " p " < " q)
(rnginex p " <= " p " < " q)
(rngexin p " < " p " <= " q)
(letin "let " p " in " q)
(letinn "let " p n>
        "in " q)

;;; Aliases
(ty (i type))
(tyn (i typen))
(opa (i opabs))
(abv (i abbrev))
(abvn (i abbrevn))
(th (i theory))
(absth (i abstractheory))
(sec (i section))
(secid (i sectionid))
(decm (i declaremodule))
(decmnm (i declaremodulenm))

(hoa (i hoare))
(hoan (i hoaren))
(ph (i phoare))
(phn (i phoaren))
(ph1 (i phoare1))
(ph1n (i phoare1n))
(eqv (i equiv))
(eqvn (i equivn))
(eho (i ehoare))
(ehon (i ehoaren))

(ax (i axiom))
(axn (i axiomn))
(lem (i lemma))
(lemby (i lemmaby))
(lempq (i lemmapq))
(lemn (i lemman))

(lemll (i lemmall))
(lemllpq (i lemmallpq))

(hoalem (i hoarelemma))
(hoalempq (i hoarelemmapq))
(hoalemn (i hoarelemman))
(hoanlemn (i hoarenlemman))
(eqvlem (i equivlemma))
(eqvlempq (i equivlemmapq))
(eqvlemn (i equivlemman))
(eqvnlemn (i equivnlemman))
(eholem (i ehoarelemma))
(eholempq (i ehoarelemmapq))
(eholemn (i ehoarelemman))
(ehonlemn (i ehoarenlemman))

(ifte (i ifthenelse))
(iften (i ifthenelsen))

;; Imperative specification
(procsig "proc " p "(" p ") : " q)
(procsiglim "proc " p "(" p ") : " p " { " q " }")

(var "var " p " : " q)
(varp (i var) ";")

(proc "proc " p "(" p ") : " p " = {" n>
      q n>
      "}" >)
(procnt "proc " p "(" p ") = {" n>
        q n>
        "}" >)
(procl "proc " p "(" p ") : " p " = { " q " }")
(proclnt "proc " p "(" p ") = { " q " }")
(procalias "proc " p " = " q)

(moduletype "module type " p " = {" n>
            q n>
            "}." >)
(moduletypep "module type " p " (" p ") = {" n>
             q n>
             "}." >)

(module "module " p " = {" n>
        q n>
        "}." >)
(modulep "module " p "(" p ") = {" n>
         q n>
         "}." >)
(modulet "module " p " : " p " = {" n>
         q n>
         "}." >)
(modulept "module " p " (" p ") : " p " = {" n>
          q n>
          "}." >)

(modulealias "module " p " = " p "(" q ").")
(modulenpalias "module " p " = " q ".")

(if "if (" p ") {" n>
    q n>
    "}" >)
(ifelse "if (" p ") {" n>
        p n>
        "} else {" > n>
        q n>
        "}" >)
(ifelifelse "if (" p ") {" n>
            p n>
            "} elif {" > n>
            p n>
            "} else {" > n>
            q n>
            "}" >)

(whiles "while (" p ") {" n>
        q
        "}" >)

(assign p "<-" q ";")
(calls p "<@" q ";")
(sample p "<$" q ";")

;;; Aliases
(procs (i procsig))
(procsl (i procsiglim))

(proca (i procalias))

(modty (i moduletype))
(modtyp (i moduletypep))

(mod (i module))
(modp (i modulep))
(modt (i modulet))
(modpt (i modulept))

(moda (i modulealias))
(modnpa (i modulenpalias))

(ife (i ifelse))
(ifee (i ifelifelse))

(whis (i whiles))

(assn (i assign))
(sam (i sample))


;; Tactics
;;; Ambient
(smt "smt(" q ")")

(movein "move=> " q)
(movegen "move: " q)

(pose "pose " p " := " q)

(have "have " p ": " q)
(haveby "have " p ": " p " by " q ".")
(haver "have ->: " q)
(havel "have <-: " q)
(haves "have /#: " q)

(applyin "apply " p " in " q)

(rewrited "rewrite (: " q ")")
(rewriter "rewrite (: " p " = " q ")")
(rewritel "rewrite -(: " p " = " q ")")
(rewritein "rewrite " p " in " q)

;;;; Aliases
(movi (i movein))
(movg (i movegen))

(appin (i applyin))

(rewd (i rewrited))
(rewr (i rewriter))
(rewl (i rewritel))
(rewin (i rewritein))


;;; Program
(proct "proc (" q ")")
(proctupbad "proc (" p ") (" q ")")
(proctupbadext "proc (" p ") (" p ") (" q ")")

(seq "seq " p " " p " : (" q ")")
(seqhoa "seq " p " : (" q ")")
(seqph "seq " p " : (" p ") (" p ") (" p ") (" p ") (" p ") (" q ")")

(sp1 "sp{1} " q)
(sp2 "sp{2} " q)

(wp1 "wp{1} " q)
(wp2 "wp{2} " q)

(rnd1 "rnd{1} " q)
(rnd2 "rnd{2} " q)

(if1 "if{1}")
(if2 "if{2}")

(while "while (" q ")")
(whileph "while (" p ") (" p ") (" p ") (" q ")")
(while1 "while{1} (" p ") (" q ")")
(while2 "while{2} (" p ") (" q ")")

(call "call (_: " q ")")
(call1 "call{1} (_: " q ")")
(call2 "call{2} (_: " q ")")
(callt "call (_: true)")
(call1t "call{1} (_: true)")
(call2t "call{2} (_: true)")

(callcont "call (_: " p " ==> " q ")")
(call1cont "call{1} (_: " p " ==> " q ")")
(call2cont "call{2} (_: " p " ==> " q ")")

(callpt "call (" q ")")
(call1pt "call{1} (" q ")")
(call2pt "call{2} (" q ")")

(callub "call (_: " p ", " q ")")
(callube "call (_: " p ", " p ", " q ")")

(ecall "ecall (" q ")")
(ecall1 "ecall{1} (" q ")")
(ecall2 "ecall{2} (" q ")")

(swap1 "swap{1} " p " " q )
(swap2 "swap{2} " p " " q )

(swapbl "swap [" p ".." p "] " q)
(swap1bl "swap{1} [" p ".." p "] " q)
(swap2bl "swap{2} [" p ".." p "] " q)

(swap1s "swap{1} " p " " p " " q)
(swap2s "swap{2} " p " " p " " q)

(inline1 "inline{1} " q)
(inline2 "inline{2} " q)

(inlines "inline *")
(inline1s "inline{1} *")
(inline2s "inline{2} *")

(inlineo "inline (" p ") " q)
(inline1o "inline{1} (" p ") " q)
(inline2o "inline{2} (" p ") " q)

(outline "outline{" p "} " p " ~ " q)
(outline1 "outline{1} " p " ~ " q)
(outline2 "outline{2} " p " ~ " q)

(outlinebl "outline{" p "} [" p ".." p "] ~ " q)
(outline1bl "outline{1} [" p ".." p "] ~ " q)
(outline2bl "outline{2} [" p ".." p "] ~ " q)

(outlinecode "outline{" p "} " p " by { " q " }")
(outline1code "outline{1} " p " by { " q " }")
(outline2code "outline{2} " p " by { " q " }")

(outlineblcode "outline{" p "} [" p ".." p "] by { " q " }")
(outline1blcode "outline{1} [" p ".." p "] by { " q " }")
(outline2blcode "outline{2} [" p ".." p "] by { " q " }")

(rcondt1 "rcondt{1} " q)
(rcondt2 "rcondt{2} " q)

(rcondf1 "rcondf{1} " q)
(rcondf2 "rcondf{2} " q)

(unroll1 "unroll{1} " q)
(unroll2 "unroll{2} " q)

(splitwhile "splitwhile " p " : (" q ")")
(splitwhile1 "splitwhile{1} " p " : (" q ")")
(splitwhile2 "splitwhile{2} " p " : (" q ")")

(fission "fission " p "!" p " @ " p ", " q)
(fission1 "fission{1} " p "!" p " @ " p ", " q)
(fission2 "fission{2} " p "!" p " @ " p ", " q)

(fusion "fusion " p "!" p " @ " p ", " q)
(fusion1 "fusion{1} " p "!" p " @ " p ", " q)
(fusion2 "fusion{2} " p "!" p " @ " p ", " q)

(alias "alias " p " with " q)
(alias1 "alias{1} " p " with " q)
(alias2 "alias{2} " p " with " q)

(aliase "alias " p " " p " = " q)
(alias1e "alias{1} " p " " p " = " q)
(alias2e "alias{2} " p " " p " = " q)

(cfold "cfold " p " " q)
(cfold1 "cfold{1} " p " " q)
(cfold2 "cfold{2} " p " " q)

(kill "kill " p " ! " q)
(kill1 "kill{1} " p " ! " q)
(kill2 "kill{2} " p " ! " q)

(transitivity "transitivity " p " (" p " ==> " p ") (" p " ==> " q ")")
(transitivitycode "transitivity{" p "} { " p " } " p " (" p " ==> " p ") (" p " ==> " q ")")

(conseq "conseq (_: " p " ==> " q ")")
(conseqpt "conseq (" q ")")
(conseqcr "conseq />")
(conseqeqvhoahoa "conseq (_: " p " ==> " p ") (_: " p " ==> " p ") (_: " p " ==> " q ")")
(conseqphhoahoa "conseq (_: " p " ==> " p ": " p ") (_: " p " ==> " q ")")
(conseqeqvhoa "conseq (" p ") (_: " p " ==> " q ")")

(byequiv "byequiv (_: " p " ==> " q ")")
(byequivpt "byequiv (" q ")")
(byequivupbad "byequiv (_: " p " ==> " p ") : " q)
(byequivupbadpt "byequiv (" p ") : " q)

(byphoare "byphoare (_: " p " ==> " q ")")
(byphoarept "byphoare (" q ")")

(bypr "bypr (" p ") (" q ")")

(existss "exists* " q)
(elims "elim* " q)

(exlimi "exlim " p " => " q)

(phoaresplitjunc "phoare split " p " " p " " q)
(phoaresplitneg "phoare split ! " p " " q)

(sim "sim : (" q ")")
(siminv "sim / " p " : (" q ")")
(simprinv "sim " p " / " p " : (" q ")")

(fel "fel " p " (" p ") (" p ") (" p ") (" p ") [" p "] (" q ")")

(rewriteequiv "rewrite equiv [{" p "} " q "]")
(rewriteequiv1 "rewrite equiv [{1} " q "]")
(rewriteequiv2 "rewrite equiv [{2} " q "]")
(rewriteequivrv "rewrite equiv [{" p "} " p " (" p " :@ " q ")]")
(rewriteequiv1rv "rewrite equiv [{1} " p " (" p " :@ " q ")]")
(rewriteequiv2rv "rewrite equiv [{2} " p " (" p " :@ " q ")]")

(procchange "proc change " p " : " q)
(procchange1 "proc change{1} " p " : " q)
(procchange2 "proc change{2} " p " : " q)

(procrewrite "proc rewrite " q)
(procrewrite1 "proc rewrite{1} " q)
(procrewrite2 "proc rewrite{2} " q)

;;; Aliases
(proctup (i proctupbad))
(proctupe (i proctupbadext))

(whi (i while))
(whiph (i whileph))
(whi1 (i while1))
(whi2 (i while2))

(callc (i callcont))
(call1c (i call1cont))
(call2c (i call2cont))

(inl1 (i inline1))
(inl2 (i inline2))

(inls (i inlines))
(inl1s (i inlines))
(inl2s (i inlines))

(inlo (i inlineo))
(inl1o (i inline1o))
(inl2o (i inline2o))

(outl (i outline))
(outl1 (i outline1))
(outl2 (i outline2))

(outlb (i outlinebl))
(outl1b (i outline1bl))
(outl2b (i outline2bl))

(outlc (i outlinecode))
(outl1c (i outline1code))
(outl2c (i outline2code))

(outlbc (i outlineblcode))
(outl1bc (i outline1blcode))
(outl2bc (i outline2blcode))

(rcot1 (i rcondt1))
(rcot2 (i rcondt2))

(rcof1 (i rcondf1))
(rcof2 (i rcondf2))

(unr1 (i unroll1))
(unr2 (i unroll2))

(splwhi (i splitwhile))
(splwhi1 (i splitwhile1))
(splwhi2 (i splitwhile2))

(fis (i fission))
(fis1 (i fission1))
(fis2 (i fission2))

(fus (i fusion))
(fus1 (i fusion1))
(fus2 (i fusion2))

(ali (i alias))
(ali1 (i alias1))
(ali2 (i alias2))

(alie (i aliase))
(ali1e (i alias1e))
(ali2e (i alias2e))

(cfo (i cfold))
(cfo1 (i cfold1))
(cfo2 (i cfolde))

(trans (i transitivity))
(transc (i transitivitycode))

(cons (i conseq))
(conspt (i conseqpt))
(conscr (i conseqcr))
(consehh (i conseqehh))
(conseh (i conseqeh))

(byeqv (i byequiv))
(byeqvpt (i byequivpt))
(byeqvub (i byequivub))
(byeqvubpt (i byequivubpt))

(byph (i byphoare))
(byphpt (i byphoarept))

(phospjc (i phoaresplitjunc))
(phospn (i phoaresplitneg))

(reweqv (i rewriteequiv))
(reweqv1 (i rewriteequiv1))
(reweqv2 (i rewriteequiv2))
(reweqvr (i rewriteequivrv))
(reweqv1r (i rewriteequiv1rv))
(reweqv2r (i rewriteequiv2rv))

(procch (i procchange))
(procch1 (i procchange1))
(procch2 (i procchange2))

(procrew (i procrewrite))
(procrew1 (i procrewrite1))
(procrew2 (i procrewrite2))

;; Miscellaneous
(Prbnd (i Pr) n>
       "<=" n>
       (i Pr))
(Prnbnd (i Prn) n>
        "<=" n>
        (i Prn))
(Prmbnd (i Prm) n>
        "<=" n>
        (i Prm))
(Prmrbnd (i Prmr) n>
         "<=" n>
         (i Prmr))

(Preq (i Pr) n>
      "=" n>
      (i Pr))
(Prneq (i Prn) n>
       "=" n>
       (i Prn))
(Prmeq (i Prm) n>
       "=" n>
       (i Prm))
(Prmreq (i Prmr) n>
        "=" n>
        (i Prmr))

(lemPrbnd "lemma " p " :" n>
          (i Prbnd) "." n>
          (i proof))
(lemPrnbnd "lemma " p " :" n>
           (i Prnbnd) "." n>
           (i proof))
(lemPrmbnd "lemma " p " &m :" n>
           (i Prmbnd) "." n>
           (i proof))
(lemPrmrbnd "lemma " p " &m :" n>
            (i Prmrbnd) "." n>
            (i proof))

(lemPreq "lemma " p " :" n>
         (i Preq) "." n>
         (i proof))
(lemPrneq "lemma " p " :" n>
          (i Prneq) "." n>
          (i proof))
(lemPrmeq "lemma " p " &m :" n>
          (i Prmeq) "." n>
          (i proof))
(lemPrmreq "lemma " p " &m :" n>
           (i Prmreq) "." n>
           (i proof))
