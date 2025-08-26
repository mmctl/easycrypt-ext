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
     "Syntax: require FILE_1 ... FILE_n.

Loads (theory corresponding to) each FILE_i into the current context.

FILE_i should be the name of an EasyCrypt file (without file extension) present
in the load path. It is allowed to have multiple `require' commands throughout a
script/session, so it is not mandatory to specify all files at once.

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

The provided theory must be present in the current context, which can be
achieved by using `require' on the files containing the theories (see the `req'
template for more information).

See the other templates starting with `clo' for more information on the cloning
mechanism and its features. Particularly, see the templates `cloas', `clowi',
`cloimp', and `cloinc' for the `as', `with', `import' and `include' features.

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
       "Creates an instance of the theory (given to `clone') in the current
context with some of its items instantiated using items from the current context
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


;;; Functional specification
(typ "type " p " = " q ".")
(typn "type " p " =" n>
      q "." >)

(op "op " p " : " p " = " q ".")
(opn "op " p " : " p " =" n>
     q "." >)
(opas "op " p " : { " p " | " p " } as " q ".")


(const "const " p " : " p " = " q ".")
(constn "const " p " : " p " =" n>
        q "." >)

(abb "abbrev " p " = " q ".")
(abbt "abbrev " p " : " p " = " q ".")
(abbn "abbrev " p " =" n>
      q "." >)

(the "theory " (p "" thid)  "." n>
     q n>
     "end " (s thid) "." >)
(absthe "abstract " (i theory))

(sec "section." n>
     q >
     "end section." >)
(secid "section" (p "" secid) "." n>
       q >
       "end section " (s secid) "." >)

(decmod "declare module " p " <: " p "{ " q " }.")
(decmodnm "declare module " p " <: " q ".")

(Pr "Pr[" p " @ " p " : " q "]")
(Prn "Pr[" n>
     p " @ " p " :" n>
     q "]" >)
(Prm "Pr[" p " @ &m : " q "]")
(Prmr "Pr[" q " @ &m : res]")

(hoa "hoare[" p " : " p " ==> " q "]")
(hoan "hoare[" n>
      p " :" n>
      p n>
      "==>" n>
      q n>
      "]" >)

(pho "phoare[" p " : " p " ==> " p "] = " q)
(phon "phoare[" n>
      p " :" n>
      p n>
      "==>" n>
      p n>
      "] = " q >)
(pho1 "phoare[" p " : " p " ==> " q "] = 1%r")
(pho1n "phoare[" n>
       p " :" n>
       p n>
       "==>" n>
       q n>
       "] = 1%r" >)

(equ "equiv[" p " ~ " p " : " p " ==> " q "]")
(equn "equiv[" n>
      p " ~ " p ":" n>
      p n>
      "==>" n>
      q n>
      "]" >)

(eho "ehoare[" p " : " p " ==> " q "]")
(ehon "ehoare[" n>
      p " :" n>
      p n>
      "==>" n>
      q n>
      "]" >)

(axi "axiom " p " : " q ".")
(axin "axiom " p " :" n>
      q "." >)

(proof "proof." > n>
       q n>
       "qed." >)
(proofpq "proof." q "qed." >)

(lem "lemma " p " : " p "." n>
     (i proof))
(lemby "lemma " p " : " p " by " q ".")
(lempq "lemma " p " : " p "." n>
       (i proofpq) >)
(lemn "lemma " p " :" n>
      p "." n>
      (i proof))
(lemnpq "lemma " p " :" n>
        p "." n>
        (i proofpq))

(lemll "lemma " p " : islossless " p "." n>
       (i proof))
(lemllpq "lemma " p " : islossless " p "." n>
         (i proofpq))

(hoal "hoare " p " : " p " : " p " ==> " p "." n>
      (i proof))
(hoalpq "hoare " p " : " p " : " p " ==> " p "." n>
        (i proofpq))
(hoaln "hoare " p " :" n>
       p " : " p " ==> " p "." n>
       (i proof))
(hoanln "hoare " p " :" n>
        p " :" n>
        p n>
        "==>" n>
        p "." n>
        (i proof))

(equl "equiv " p " : " p " ~ " p " : " p " ==> "p "." n>
      (i proof))
(equlpq "equiv " p " : " p " ~ " p " : " p " ==> "p "." n>
        (i proofpq))
(equln "equiv " p " :" n>
       p " ~ " p " : " p " ==> "p "." n>
       (i proof))
(equnln "equiv " p " :" n>
        p " ~ " p " :" n>
        p n>
        "==>" n>
        p "." n>
        (i proof))

(ehol "ehoare " p " : " p " : " p " ==> " p "." n>
      (i proof))
(eholpq "ehoare " p " : " p " : " p " ==> " p "." n>
        (i proofpq))
(eholn "ehoare " p " :" n>
       p " : " p " ==> " p "." n>
       (i proof))
(eholn "ehoare " p " :" n>
       p " :" n>
       p n>
       "==>" n>
       p "." n>
       (i proof))

(fun "fun (" p ") => " q)
(funn "fun (" p ") =>" n>
      q)
(for "forall (" p "), " q)
(forn "forall (" p ")," n>
      q)
(exi "exists (" p "), " q)
(exin "exists (" p ")," n>
      q)
(iftheels "if " p " then " p " else " q)
(iftheelsn "if " p n>
           "then " p n>
           "else " q)

(ge0 "0 <= " q)
(gt0 "0 < " q)
(rngii p " <= " p " <= " q)
(rngee p " < " p " < " q)
(rngie p " <= " p " < " q)
(rngei p " < " p " <= " q)
(letin "let " p " in " q)
(letinn "let " p n>
        "in " q)


;;; Imperative specification
(pros "proc " p "(" p ") : " q)
(prosl "proc " p "(" p ") : " p " { " q " }")

(var "var " p " : " q)
(varp (i var) ";")

(pro "proc " p "(" p ") = {" n>
     q n>
     "}" >)
(prot "proc " p "(" p ") : " p " = {" n>
      q n>
      "}" >)
(prol "proc " p "(" p ") = { " q " }")
(protl "proc " p "(" p ") : " p " = { " q " }")
(proa "proc " p " = " q)

(modtyp "module type " p " = {" n>
        q n>
        "}." >)
(modtypp "module type " p " (" p ") = {" n>
         q n>
         "}." >)

(mod "module " p " = {" n>
     q n>
     "}." >)
(modp "module " p "(" p ") = {" n>
      q n>
      "}." >)
(modt "module " p " : " p " = {" n>
      q n>
      "}." >)
(modpt "module " p " (" p ") : " p " = {" n>
       q n>
       "}." >)

(moda "module " p " = " p "(" q ").")
(modap "module " p " = " q ".")

(if "if (" p ") {" n>
    q n>
    "}" >)
(ifels "if (" p ") {" n>
       p n>
       "} else {" > n>
       q n>
       "}" >)
(ifeliels "if (" p ") {" n>
          p n>
          "} elif {" > n>
          p n>
          "} else {" > n>
          q n>
          "}" >)

(whis "while (" p ") {" n>
      q
      "}" >)

(ass p "<-" q ";")
(cals p "<@" q ";")
(sam p "<$" q ";")


;; Tactics
;;; Ambient
(smt "smt(" q ")")

(movi "move=> " q)
(movg "move: " q)

(pos "pose " p " := " q)

(hav "have " p ": " q)
(havby "have " p ": " p " by " q ".")
(havr "have ->: " q)
(havl "have <-: " q)
(havs "have /#: " q)

(appin "apply " p " in " q)

(rewd "rewrite (: " q ")")
(rewr "rewrite (: " p " = " q ")")
(rewl "rewrite -(: " p " = " q ")")
(rewin "rewrite " p " in " q)


;;; Program
(proc "proc (" q ")")
(procub "proc (" p ") (" q ")")
(procube "proc (" p ") (" p ") (" q ")")

(seq "seq " p " " p " : (" q ")")
(seqh "seq " p " : (" q ")")
(seqp "seq " p " : (" p ") (" p ") (" p ") (" p ") (" p ") (" q ")")

(sp1 "sp{1} " q)
(sp2 "sp{2} " q)

(wp1 "wp{1} " q)
(wp2 "wp{2} " q)

(rnd1 "rnd{1} " q)
(rnd2 "rnd{2} " q)

(if1 "if{1}")
(if2 "if{2}")

(whi "while (" q ")")
(whip "while (" p ") (" p ") (" p ") (" q ")")
(whi1 "while{1} (" p ") (" q ")")
(whi2 "while{2} (" p ") (" q ")")

(cal "call (_: " q ")")
(cal1 "call{1} (_: " q ")")
(cal2 "call{2} (_: " q ")")
(calt "call (_: true)")
(cal1t "call{1} (_: true)")
(cal2t "call{2} (_: true)")

(calc "call (_: " p " ==> " q ")")
(cal1c "call{1} (_: " p " ==> " q ")")
(cal2c "call{2} (_: " p " ==> " q ")")

(calpt "call (" q ")")
(cal1pt "call{1} (" q ")")
(cal2pt "call{2} (" q ")")

(calub "call (_: " p ", " q ")")
(calube "call (_: " p ", " p ", " q ")")

(eca "ecall (" q ")")
(eca1 "ecall{1} (" q ")")
(eca2 "ecall{2} (" q ")")

(swa1 "swap{1} " p " " q )
(swa2 "swap{2} " p " " q )

(swabl "swap [" p ".." p "] " q)
(swa1bl "swap{1} [" p ".." p "] " q)
(swa2bl "swap{2} [" p ".." p "] " q)

(swa1s "swap{1} " p " " p " " q)
(swa2s "swap{2} " p " " p " " q)

(inl1 "inline{1} " q)
(inl2 "inline{2} " q)

(inls "inline *")
(inl1s "inline{1} *")
(inl2s "inline{2} *")

(inlo "inline (" p ") " q)
(inl1o "inline{1} (" p ") " q)
(inl2o "inline{2} (" p ") " q)

(out "outline{" p "} " p " ~ " q)
(out1 "outline{1} " p " ~ " q)
(out2 "outline{2} " p " ~ " q)

(outbl "outline{" p "} [" p ".." p "] ~ " q)
(out1bl "outline{1} [" p ".." p "] ~ " q)
(out2bl "outline{2} [" p ".." p "] ~ " q)

(outc "outline{" p "} " p " by { " q " }")
(out1c "outline{1} " p " by { " q " }")
(out2c "outline{2} " p " by { " q " }")

(outblc "outline{" p "} [" p ".." p "] by { " q " }")
(out1blc "outline{1} [" p ".." p "] by { " q " }")
(out2blc "outline{2} [" p ".." p "] by { " q " }")

(rco1 "rcondt{1} " q)
(rco2 "rcondt{2} " q)

(rco1 "rcondf{1} " q)
(rco2 "rcondf{2} " q)

(unr1 "unroll{1} " q)
(unr2 "unroll{2} " q)

(splwhi "splitwhile " p " : (" q ")")
(splwhi1 "splitwhile{1} " p " : (" q ")")
(splwhi2 "splitwhile{2} " p " : (" q ")")

(fis "fission " p "!" p " @ " p ", " q)
(fis1 "fission{1} " p "!" p " @ " p ", " q)
(fis2 "fission{2} " p "!" p " @ " p ", " q)

(fus "fusion " p "!" p " @ " p ", " q)
(fus1 "fusion{1} " p "!" p " @ " p ", " q)
(fus2 "fusion{2} " p "!" p " @ " p ", " q)

(ali "alias " p " with " q)
(ali1 "alias{1} " p " with " q)
(ali2 "alias{2} " p " with " q)

(alie "alias " p " " p " = " q)
(ali1e "alias{1} " p " " p " = " q)
(ali2e "alias{2} " p " " p " = " q)

(cfo "cfold " p " " q)
(cfo1 "cfold{1} " p " " q)
(cfo2 "cfold{2} " p " " q)

(kil "kill " p " ! " q)
(kil1 "kill{1} " p " ! " q)
(kil2 "kill{2} " p " ! " q)

(tra "transitivity " p " (" p " ==> " p ") (" p " ==> " q ")")
(trac "transitivity{" p "} { " p " } " p " (" p " ==> " p ") (" p " ==> " q ")")

(cons "conseq (_: " p " ==> " q ")")
(conspt "conseq (" q ")")
(conscr "conseq />")
(consehh "conseq (_: " p " ==> " p ") (_: " p " ==> " p ") (_: " p " ==> " q ")")
(consphh "conseq (_: " p " ==> " p ": " p ") (_: " p " ==> " q ")")
(conseh "conseq (" p ") (_: " p " ==> " q ")")

(bye "byequiv (_: " p " ==> " q ")")
(byept "byequiv (" q ")")
(byeub "byequiv (_: " p " ==> " p ") : " q)
(byeubpt "byequiv (" p ") : " q)

(byp "byphoare (_: " p " ==> " q ")")
(byppt "byphoare (" q ")")

(bypr "bypr (" p ") (" q ")")

(exis "exists* " q)
(elis "elim* " q)

(exli "exlim " p " => " q)

(phosplj "phoare split " p " " p " " q)
(phospln "phoare split ! " p " " q)

(sim "sim : (" q ")")
(simi "sim / " p " : (" q ")")
(simpi "sim " p " / " p " : (" q ")")

(fel "fel " p " (" p ") (" p ") (" p ") (" p ") [" p "] (" q ")")

(rewequ "rewrite equiv [{" p "} " q "]")
(rewequ1 "rewrite equiv [{1} " q "]")
(rewequ2 "rewrite equiv [{2} " q "]")
(rewequrv "rewrite equiv [{" p "} " p " (" p " :@ " q ")]")
(rewequ1rv "rewrite equiv [{1} " p " (" p " :@ " q ")]")
(rewequ2rv "rewrite equiv [{2} " p " (" p " :@ " q ")]")

(procha "proc change " p " : " q)
(procha1 "proc change{1} " p " : " q)
(procha2 "proc change{2} " p " : " q)

(prorew "proc rewrite " q)
(prorew1 "proc rewrite{1} " q)
(prorew2 "proc rewrite{2} " q)


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
