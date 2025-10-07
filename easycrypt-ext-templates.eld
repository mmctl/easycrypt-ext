;; easycrypt.eld
;; Tempel templates for easycrypt mode

easycrypt-mode

;;; Comments and documentation
(com "(* " q " *)"
     :ann
     "Comment"
     :doc
     "Regular, non-documentation comment on a single line.")

(comn "(*" n>
      q n
      "*)" >
      :ann
      "Comment (\\n)"
      :doc
      "Regular, non-documentation comment with newline(s), putting the opener
and closer on separate lines.")

(docc "(*& " q " &*)"
      :ann
      "Documentation comment"
      :doc
      "Item documentation comment on a single line.

An item documentation comment is `linked' to the next item in the file, serving
as (part of) its documentation. For example, this will show up alongside the
`linked' item in the generated documentation for this file.")

(docn "(*&" n>
      q n
      "&*)" >
      :ann
      "Documentation comment (\\n)"
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
      :ann
      "File documentation comment"
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
     :ann
     "require"
     :doc
     "Syntax := require FILE_1 ... FILE_n.

Loads (theory corresponding to) each FILE_i. FILE_i should be the name of an
EasyCrypt file (without file extension) present in the load path. It is allowed
to have multiple `require' commands throughout a script/session, so it is not
mandatory to specify all files at once.

Example:
require AllCore List.
require Distr.")

(imp "import " q "."
     :ann
     "import"
     :doc
     "Syntax := import THEORY_1 ... THEORY_n.

Loads (namespace corresponding to) each THEORY_i. THEORY_i should be in the
current context, which can be achieved by using `require' on the files
containing the theories (see the `req' template for more information).

Loading a namespace enables direct referencing to items from that
namespace (i.e., without explicitly specifying the namespace).

Example:
import AllCore.
import List Distr.")

(reqimp "require import " q "."
        :ann
        "require import"
        :doc
        "Syntax := require import FILE1 ... FILE_N.

Loads (theory and namespace corresponding to) each FILE_i.

Essentially syntactic sugar for a `require' statement followed by an `import'
statement with the same arguments.

See the `req' and `imp' templates for more information on `require' and
`import'.

Example:
require import AllCore List Distr.")

(froreq "from " p " require " q
        :ann
        "from require"
        :doc
        "Syntax := from LIBRARY require FILE_1 ... FILE_N.

Loads (theory corresponding to) each FILE_i from library LIBRARY.

LIBRARY should be in the current load path, typically added via an EasyCrypt
project file or the `-I' command line option.

See the `req' template for more information on `require'.

Example:
from Jasmin require JModel JArray.")

(froreqimp "from " p " require import " q
           :ann
           "from require import"
           :doc
           "Syntax := from LIBRARY require import FILE_1 ... FILE_N.

Loads (theory and namespace corresponding to) each FILE_i from library LIBRARY.

Essentially syntactic sugar for a `from require' statement followed by an
`import' statement with the same arguments.

See the `froreq' and `imp' templates for more information on
`from require' and `import'.

Example:
from Jasmin require import JModel JArray.")

(clo "clone " q "."
     :ann
     "clone"
     :doc
     "Syntax := clone THEORY.

Creates an instance of THEORY. THEORY should be in the current context, which can
be achieved by using `require' on the files containing THEORY (see the `req'
template for more information).

Instantiating a (potentially abstract) theory and its components through cloning
allows for the reuse of definitions/results from the theory in different
contexts, facilitating modularity. Only a single theory can be cloned at a time.

See the other templates starting with `clo' for more information on the cloning
mechanism and its features. Particularly, see the templates `cloas', `clowi',
`cloimp', and `cloinc' for the use of `as', `with', `import' and `include'
with `clone'.

Example:
clone KeyedHashFunctions.")

(cloas "clone " p " as " q "."
       :ann
       "clone as"
       :doc
       "Syntax := clone THEORY as INST.

Creates an instance of THEORY under the name INST.

See the `clo' template for more information on `clone'.

Example:
clone KeyedHashFunctions as KHFs.")

(clowi "clone " p " with" n>
       q "."
       :ann
       "clone with"
       :doc
       "Syntax := clone THEORY with INSTSPEC.

Creates an instance of THEORY with its items instantiated as specified by
INSTSPEC.

INSTSPEC should be a comma-separated list (whitespace is allowed but ignored)
with entries of the form `<itemkind> <origitemname> <inst> <newitemexpr>':
- `<itemkind>' is the kind of the item to
  instantiate, e.g., `type', `op'.
- `<origitemname>' is the name of the item to instantiate.
- `<inst>' is the type of instantiation, which may be one of `<-',
   `<=', or `='. The first fully replaces every reference to the original item from
   THEORY, removing the original definition; the second fully replaces
   every reference to the original item from THEORY, changing the
   original definition to be an equality with the new item; the third keeps every
   reference to the original item from THEORY, only changing the
   original definition to be an equality with the new item.
- `<newitemexpr>' is an expression, typically involving items from the current
   context, to instantiate `<origitemname>'  with.

The list should be terminated with a period (`.').

When you instantiate abstract items that have axiomatized properties in THEORY,
you probably (should) want to prove these axioms actually hold the
instantiations. This can be achieved by using the special keyword `proof' as the
final entry of INSTSPEC. There should be no comma between the last
actual (instantiation) entry and `proof'. As arguments, `proof' takes a
comma-separated list of axioms to prove. You can pass `*' to prove every axiom.

See the `clo' template for more information on `clone'.

Example:
clone KeyedHashFunctions with
  type key_t <- keys,
  type in_t <- input,
  type out_t <- output,
  op f <- (fun k x => hash (k ++ x))

  proof *.")

(cloaswi "clone " p " as " p " with" n>
         q "."
         :ann
         "clone as with"
         :doc
         "Syntax := clone THEORY as INSTNAME with INSTSPEC

Creates an instance of THEORY under the name INSTNAME with its items
instantiated as specified by INSTSPEC.

See the `clo', `cloas', and `clowi' templates for more information on
`clone' and `as'/`with'.

Example:
clone KeyedHashFunctions as KHFs with
  type key_t <- keys,
  type in_t <- input,
  type out_t <- output,
  op f <- (fun k x => hash (k ++ x))

  proof *.")

(cloimp "clone import " q "."
        :ann
        "clone import"
        :doc
        "Syntax := clone import THEORY.

Creates an instance of THEORY and loads the corresponding namespace.

Essentially syntactic sugar for a `clone' statement followed by an `import'
statement with the same argument.

See the `clo' and `imp' templates for more information on `clone' and
`import'.

Example:
clone import KeyedHashFunctions.")

(cloimpas "clone import " p " as " q "."
          :ann
          "clone import as"
          :doc
          "Syntax := clone import THEORY as INST.

Creates an instance of THEORY under the name INST and loads the
corresponding namespace.

Essentially syntactic sugar for a `clone as' statement followed by an `import'
statement with INST.

See the `cloas' and `imp' templates for more information on `clone as' and
`import'.

Example:
clone import KeyedHashFunctions as KHFs.")

(cloimpwi "clone import " p " with" n>
          q "."
          :ann
          "clone import with"
          :doc
          "Syntax := clone import THEORY with INSTSPEC.

Creates an instance of THEORY with its items instantiated as specified by
INSTSPEC, and loads the corresponding namespace.

Essentially syntactic sugar for a `clone with' statement followed by an `import'
statement with THEORY.

See the `clowi' and `imp' templates for more information on `clone with' and
`import'.

Example:
clone import KeyedHashFunctions with
  type key_t <- keys,
  type in_t <- input,
  type out_t <- output,
  op f <- (fun k x => hash (k ++ x))

  proof *.")

(cloimpaswi "clone import " p " as " p " with" n>
            q "."
            :ann
            "clone import as with"
            :doc
            "Syntax := clone import THEORY as INSTNAME with INSTSPEC.

Creates an instance of THEORY under the name INSTNAME with its items
instantiated as specified by INSTSPEC, and loads the corresponding namespace.

Essentially syntactic sugar for a `clone as with' statement followed by an
`import' statement with INSTNAME.

See the `cloaswi' and `imp' templates for more information on `clone as with'
and `import'.

Example:
clone import KeyedHashFunctions as KHFs with
  type key_t <- keys,
  type in_t <- input,
  type out_t <- output,
  op f <- (fun k x => hash (k ++ x))

  proof *.")

(cloinc "clone include " q "."
        :ann
        "clone include"
        :doc
        "Syntax := clone include THEORY.

Creates an instance of THEORY and includes it as if the
code of the resulting instance was inserted literally.

Certain statements do not have the same effect as they would have if the
statements were actually inserted literally, particularly some
\"meta-statements\" like `import'.

See the `clo' template for more information on `clone'.

Example:
clone include KeyedHashFunctions.")

(cloincas "clone include " p " as " q "."
          :ann
          "clone include as"
          :doc
          "Syntax := clone include THEORY as INST.

Creates an instance of THEORY under the name INST and includes it as if the
code of the resulting instance was inserted literally.

See the `cloinc' and `cloas' templates for more information on `clone include'
and `as'.

clone include KeyedHashFunctions as KHFs.")

(cloincwi "clone include " p " with" n>
          q "."
          :ann
          "clone include with"
          :doc
          "Syntax := clone include THEORY with INSTSPEC.

Creates an instance of THEORY with its items instantiated as specified by
INSTSPEC, and includes it as if the code of the resulting
instance was inserted literally.

See the `cloinc' and `clowi' templates for more information on `clone include'
and `with'.

Example:
clone include KeyedHashFunctions with
  type key_t <- keys,
  type in_t <- input,
  type out_t <- output,
  op f <- (fun k x => hash (k ++ x))

  proof *.")

(cloincaswi "clone include " p " as " p " with" n>
            q "."
            :ann
            "clone include as with"
            :doc
            "Syntax := clone include THEORY as INSTNAME with INSTSPEC.

Creates an instance of THEORY under the name INSTNAME with its items
instantiated as specified by INSTSPEC, and includes it as
if the code of the resulting instance was inserted literally.

See the `cloinc', `cloas', and `clowi' templates for more information
on `clone include' and `as/with'.

Example:
clone include KeyedHashFunctions as KHFs with
  type key_t <- keys,
  type in_t <- input,
  type out_t <- output,
  op f <- (fun k x => hash (k ++ x))

  proof *.")

(hinsim "hint simplify " q
        :ann
        "hint simplify"
        :doc
        "Syntax := hint simplify AXLEM_1, ..., AXLEM_N.

Adds each axiom/lemma AXLEM_i as hint for the `simplify' tactic.

Example:
hint simplify oget_some, oget_none.")

(hinrew "hint rewrite " p " : " q
        :ann
        "hint rewrite"
        :doc
        "Adds the specified axioms/lemmas as hints for the `rewrite' tactic.")
(hinex "hint exact " p " : " q
       :ann
       "hint exact"
       :doc
       "Adds axioms/lemmas as hints for the `exact' tactic.")


;;; Functional specification
(typ "type " q "."
     :ann
     "type (no def)"
     :doc
     "Syntax := type TYPE.

Declares a type TYPE without definition.

Example:
type t.
type u.
type keys.")

(typd "type " p " = " q "."
      :ann
      "type (def)"
      :doc
      "Syntax := type TYPENAME = TYPEEXPR.

Defines a type TYPENAME as TYPEEXPR.

TYPEEXPR should be a valid type expression, including:
- basic/built-in types (e.g., int, bool)
- product types (e.g., int * bool)
- function types (e.g., int -> bool).
- (applied) type constructors (e.g., int list)
- sum types (e.g., [ First | Second ] )
- record types (e.g., { x : int, y : bool })

Example:
type t = int.
type u = real * bool.

type m = t -> u.")

(typn "type " p " =" n>
      q "." >
      :ann
      "type (def + \\n)"
      :doc
      "Syntax := type TYPENAME = TYPEEXPR.

Defines a type TYPENAME as TYPEEXPR.

Semantically identical to the `typd' template; differs only in formatting. See
`typd' for details and examples.")

(op "op " q "."
    :ann
    "op (no def)"
    :doc
    "Syntax := OP : TYPE
Syntax (alternative): OP (PARAM_1 : TYPE_1) ... (PARAM_N : TYPE_N) : RESTYPE.

Declares an operator OP without definition. In the first syntax form, TYPE
is a function type that encodes the types of the parameters and the return type.
The second syntax form is equivalent, but allows naming parameters explicitly
for documentation purposes. In this form, successive parameters of the same type
may be grouped, e.g., (PARAM_1 PARAM_2 PARAM_3 : TYPE).

(N.B. letting TYPE be TYPE_1 -> ... -> TYPE_N -> RESTYPE gives an equivalent
formalization of the second form in the first.)

Example:
op f (x : int) (y : int) : bool.
op g (x y : int) : bool.
op h : int -> int -> bool.")

(opd "op " p " : " p " = " q "."
     :ann
     "op (def)"
     :doc
     "Syntax := op OP (PARAM_1 : TYPE_1) ... (PARAM_N : TYPE_N) : RESTYPE = EXPR.

Defines an operator OP as EXPR. This operator has n parameters,
where the i-th is of type TYPE_i, and evaluates to a value of type RESTYPE.

Note:
- EXPR need not use all (or any) parameters, but must evaluate to a value of type RESTYPE.
- Parameter types and the return type (including colons) may be omitted if they can be inferred from EXPR.
- Parameters of the same type may be grouped, e.g., (PARAM_1 PARAM_2 PARAM_3 : TYPE).

See template `op' for more information about operator declarations.

Example:
op f (x : int) (y : int) : int = x + y.
op g (x y : int) = x + y.")

(opn "op " p " : " p " =" n>
     q "." >
     :ann
     "op (def + \\n)"
     :doc
     "Syntax := op OP (PARAM_1 : TYPE_1) ... (PARAM_N : TYPE_N) : RESTYPE = EXPR.

Defines an operator OP as EXPR. This operator has n parameters,
where the i-th is of type TYPE_i, and evaluates to a value of type RESTYPE.

Semantically identical to the `opd' template; differs only in formatting.
See `opd' for details and examples.")

(opas "op " p " : { " p " | " p " } as " q "."
      :ann
      "op as (axiom)"
      :doc
      "Syntax := op OP : { TYPE | AXIOMSTAT } as AXIOMNAME.

Declares an operator OP of type TYPE, together with an
axiom AXIOMNAME asserting AXIOMSTAT.

Typically used to axiomatize a fundamental property of the operator,
so AXIOMSTAT often refers to OP. However, this is not enforced.

Example:
op f : { int -> int | forall (x y : int), x <= y => f x <= f y } as monotonic_f.")

(const "const " p " : " p "."
       :ann
       "constant (no def)"
       :doc
       "Syntax := const CONST : TYPE.

Defines a constant CONST of type TYPE without definition.

Example:
const n : int.")

(constd "const " p " : " p " = " q "."
        :ann
        "const (def)"
        :doc
        "Syntax := const CONST : TYPE = EXPR.

Defines a constant CONST as EXPR, which evaluates to a value of type
TYPE.

The type (and colon) may be omitted if it can be inferred from EXPR.

Example:
const t : bool = true.
const n = 5.")

(constn "const " p " : " p " =" n>
        q "." >
        :ann
        "const (def + \\n)"
        :doc
        "Syntax := const CONST : TYPE = EXPR.

Defines a constant CONST as EXPR, which evaluates to a value of type
TYPE.

Semantically identical to the `constd' template; differs only in formatting.
See `constd' for details and examples.")

(constas "const " p " : { " p " | " p " } as " q "."
         :ann
         "const as (axiom)"
         :doc
         "Syntax := const CONST : { TYPE | AXIOMSTAT } as AXIOMNAME.

Declares a constant CONST of type TYPE, and an axiom AXIOMNAME stating
AXIOMSTAT.

Typically used to axiomatize a fundamental property of the constant, so
AXIOMSTAT often refers to CONST. However, this is not enforced.

Example:
const n : { int | 0 <= n } as ge0_n.")

(abb "abbrev " p " : " p " = " q "."
     :ann
     "abbrev"
     :doc
     "Syntax := abbrev ABBREV (PARAM_1 : TYPE_1) ... (PARAM_N : TYPE_N) : RESTYPE = EXPR.

Defines an abbreviation ABBREV as EXPR. This abbreviation takes n
parameters, where the i-th has type TYPE_i, and evaluates to a value of type
RESTYPE.

Note:
- EXPR need not use all (or any) parameters, but must evaluate to a value of type RESTYPE.
- Parameter types and the return type (including colons) may be omitted if they can be inferred from EXPR.
- Parameters of the same type may be grouped, e.g., (PARAM_1 PARAM_2 PARAM_3 : TYPE).

Essentially an operator definition (see the `op' template) with a restricted set
of possible EXPR. In addition, when printing an abbrevation, its definitions is
printed instead of its name.

Example: abbrev max (x y : int) = if x <= y then y else x.")

(abbn "abbrev " p " : " p " =" n>
      q "." >
      :ann
      "abbrev (\\n)"
      :doc
      "Syntax := abbrev ABBREV (PARAM_1 : TYPE_1) ... (PARAM_N : TYPE_N) : RESTYPE = EXPR.

Defines an abbreviation ABBREV as EXPR. This abbreviation takes n
parameters, where the i-th has type TYPE_i, and evaluates to a value of type
RESTYPE.

Semantically identical to the `abb' template; differs only in formatting.
See `abb' for details and examples.")

(the "theory " (p "" thid)  "." n>
     q n>
     "end " (s thid) "." >
     :ann
     "theory"
     :doc
     "Syntax := theory THEORY. [BODY] end THEORY.

Defines a theory THEORY. [BODY] represents the body of the
theory, which can be any sequence of sentences valid in a theory.

A theory typically contains a collection of related items (e.g.,
definitions, properties, specifications, et cetera).

A theory can be cloned for (re)use in different contexts, where its (abstract)
items may be instantiated with other items from the considered context, allowing
for modularity and flexibility. See the templates starting with `clo' for more
information on the cloning mechanism and its features.

Example:
theory KeyedHashFunctions.
type key_t.
type in_t.
type out_t.

op f.
end KeyedHashFunctions.")

(absthe "abstract " (i the)
        :ann
        "abstract theory"
        :doc
        "Syntax := abstract theory THEORY. [BODY] end THEORY.

Defines an abstract theory THEORY. [BODY] represents the body of the
theory, which can be any sequence of sentences valid in a theory.

An abstract theory is similar to a regular theory, but must be cloned before it
can be accessed. Although instantiating any items during cloning is optional,
abstract theories are typically designed to be instantiated (at least
partially).

See the `the' and `clo' templates for more information on theories and cloning.

Example:
abstract theory KeyedHashFunctions.
type key_t.
type in_t.
type out_t.

op f.
end KeyedHashFunctions.")

(sec "section." n>
     q n>
     "end section." >
     :ann
     "section (no name)"
     :doc
     "Syntax := section. [BODY] end section.

Defines a section. [BODY] represents the body of the
section, which can be any sequence of sentences valid in a section.")

(secid "section" (p "" secid) "." n>
       q n>
       "end section " (s secid) "." >
       :ann
       "section (name)"
       :doc
       "Syntax := section SECTION. [BODY] end section SECTION.

Defines a section SECTION. [BODY] represents the body of the
section, which can be any sequence of sentences valid in a section.")

(decty "declare type " q "."
       :ann
       "declare type"
       :doc
       "Syntax := declare type TYPE.")

(decop "declare op " p " : " q "."
       :ann
       "declare op"
       :doc
       "Syntax := declare op OP : TYPE.")

(decopas "declare op " p " : { " p " | " p " } as " q "."
         :ann
         "declare op as (axiom)"
         :doc
         "Syntax := declare op OP : { TYPE | AXIOMSTAT } as AXIOMNAME.")

(deccon "declare const " p " : " q "."
        :ann
        "declare const"
        :doc
        "Syntax := declare const CONST : TYPE.")

(deconas "declare const " p " : { " p " | " p " } as " q "."
         :ann
         "declare const as (axiom)"
         :doc
         "Syntax := declare const CONST : { TYPE | AXIOMSTAT } as AXIOMNAME.")

(decmod "declare module " p " <: " q "."
        :ann
        "declare module (no restr)"
        :doc
        "Syntax := declare module MODNAME <: MODTYPE.")

(decmodr "declare module " p " <: " p "{ " q " }."
         :ann
         "declare module (restr)"
         :doc
         "Syntax := declare module MODNAME <: MODTYPE { MODRESTR }.")

(Pr "Pr[" p " @ " p " : " q "]"
    :ann
    "Pr"
    :doc
    "Syntax := Pr[MOD(MODARG_1, ..., MODARG_N).PROC(ARG_1, ..., ARG_N) @ MEM : EVENT]")

(Prn "Pr[" n>
     p " @ " p " :" n>
     q "]" >
     :ann
     "Pr (\\n)"
     :doc
     "Syntax := Pr[MOD(MODARG_1, ..., MODARG_N).PROC(ARG_1, ..., ARG_N) @ MEM : EVENT]")

(Prm "Pr[" p " @ &m : " q "]"
     :ann
     "Pr (&m)"
     :doc
     "Syntax := Pr[MOD(MODARG_1, ..., MODARG_N).PROC(ARG_1, ..., ARG_N) @ MEM : EVENT]")

(Prmr "Pr[" q " @ &m : res]"
      :ann
      "Pr (&m + res)"
      :doc
      "Syntax := Pr[MOD(MODARG_1, ..., MODARG_N).PROC(ARG_1, ..., ARG_N) @ MEM : EVENT]")

(hoa "hoare[" p " : " p " ==> " q "]"
     :ann
     "hoare"
     :doc
     "Syntax := hoare[MOD(MODARG_1, ..., MODARG_N).PROC : PRE ==> POST]")

(hoan "hoare[" n>
      p " :" n>
      p n>
      "==>" n>
      q n>
      "]" >
      :ann
      "hoare (\\n)"
      :doc
      "Syntax := hoare[MOD(MODARG_1, ..., MODARG_N).PROC : PRE ==> POST]")

(pho "phoare[" p " : " p " ==> " p "] " q
     :ann
     "phoare"
     :doc
     "Syntax := phoare[MOD(MODARG_1, ..., MODARG_N).PROC : PRE ==> POST] REL VAL")

(phon "phoare[" n>
      p " :" n>
      p n>
      "==>" n>
      p n>
      "] " q >
      :ann
      "phoare (\\n)"
      :doc
      "Syntax := phoare[MOD(MODARG_1, ..., MODARG_N).PROC : PRE ==> POST] REL VAL")

(pho1 "phoare[" p " : " p " ==> " q "] = 1%r"
      :ann
      "phoare (=1%r)"
      :doc
      "Syntax := phoare[MOD(MODARG_1, ..., MODARG_N).PROC : PRE ==> POST] = 1%r")

(pho1n "phoare[" n>
       p " :" n>
       p n>
       "==>" n>
       q n>
       "] = 1%r" >
       :ann
       "phoare (=1%r + \\n)"
       :doc
       "Syntax := phoare[MOD(MODARG_1, ..., MODARG_N).PROC : PRE ==> POST] = 1%r")

(equ "equiv[" p " ~ " p " : " p " ==> " q "]"
     :ann
     "equiv"
     :doc
     "Syntax := equiv[MOD_1(MODARG_11, ..., MODARG_1n).PROC1 ~ MOD_2(MODARG_21, ..., MODARG_2n).PROC_2 : PRE ==> POST]")

(equn "equiv[" n>
      p " ~ " p ":" n>
      p n>
      "==>" n>
      q n>
      "]" >
      :ann
      "equiv (\\n)"
      :doc
      "Syntax := equiv[MOD_1(MODARG_11, ..., MODARG_1n).PROC1 ~ MOD_2(MODARG_21, ..., MODARG_2n).PROC_2 : PRE ==> POST]")

(eho "ehoare[" p " : " p " ==> " q "]"
     :ann
     "ehoare"
     :doc
     "Syntax := ehoare[MOD(MODARG_1, ..., MODARG_N).PROC : PRE ==> POST]")

(ehon "ehoare[" n>
      p " :" n>
      p n>
      "==>" n>
      q n>
      "]" >
      :ann
      "ehoare (\\n)"
      :doc
      "Syntax := ehoare[MOD(MODARG_1, ..., MODARG_N).PROC : PRE ==> POST]")

(axi "axiom " p " : " q "."
     :ann
     "axiom"
     :doc
     "Syntax := axiom AXIOM (PARAM_1 : TYPE_1) ... (PARAM_N : TYPE_N) : STAT.")

(axin "axiom " p " :" n>
      q "." >
      :ann
      "axiom (\\n)"
      :doc
      "Syntax := axiom AXIOM (PARAM_1 : TYPE_1) ... (PARAM_N : TYPE_N) : STAT.")

(proof "proof." > n>
       q n>
       "qed." >
       :ann
       "proof"
       :doc
       "Syntax := proof. [BODY] qed.")

(proofl "proof." q " qed."
        :ann
        "proof (one-liner)"
        :doc
        "Syntax := proof. [BODY] qed.")

(lem "lemma " p " : " p "." n>
     (i proof)
     :ann
     "lemma"
     :doc
     "Syntax := lemma LEMMA (PARAM_1 : TYPE_1) ... (PARAM_N : TYPE_N) : STAT.")

(lemby "lemma " p " : " p " by " q "."
       :ann
       "lemma by"
       :doc
       "Syntax := lemma LEMMA (PARAM_1 : TYPE_1) ... (PARAM_N : TYPE_N) : LEMMA by PROOFSENT.")

(lemn "lemma " p " :" n>
      p "." n>
      (i proof)
      :ann
      "lemma (\\n)"
      :doc
      "Syntax := lemma LEMMA (PARAM_1 : TYPE_1) ... (PARAM_N : TYPE_N) : STAT.")

(lemll "lemma " p " : islossless " p "." n>
       (i proof)
       :ann
       "lemma islossless"
       :doc
       "Syntax := lemma LEMMA : islossless MOD(MODARG_1, ..., MODARG_N).PROC.")

(hoal "hoare " p " : " p " : " p " ==> " p "." n>
      (i proof)
      :ann
      "hoare lemma"
      :doc
      "Syntax := hoare LEMMA (PARAM_1 : TYPE_1) ... (PARAM_N : TYPE_N) : MOD(MODARG_1, ..., MODARG_N).PROC : PRE ==> POST.")

(hoaln "hoare " p " :" n>
       p " : " p " ==> " p "." n>
       (i proof)
       :ann
       "hoare lemma (\\n)"
       :doc
       "Syntax := hoare LEMMA (PARAM_1 : TYPE_1) ... (PARAM_N : TYPE_N) : MOD(MODARG_1, ..., MODARG_N).PROC : PRE ==> POST.")

(hoanln "hoare " p " :" n>
        p " :" n>
        p n>
        "==>" n>
        p "." n>
        (i proof)
        :ann
        "hoare lemma (\\n x2)"
        :doc
        "Syntax := hoare LEMMA (PARAM_1 : TYPE_1) ... (PARAM_N : TYPE_N) : MOD(MODARG_1, ..., MODARG_N).PROC : PRE ==> POST.")

(equl "equiv " p " : " p " ~ " p " : " p " ==> " p "." n>
      (i proof)
      :ann
      "equiv lemma"
      :doc
      "Syntax := equiv LEMMA (PARAM_1 : TYPE_1) ... (PARAM_N : TYPE_N) : MOD_1(MODARG_11, ..., MODARG_1n).PROC_1 ~ MOD_2(MODARG_21, ..., MODARG_2n).PROC_2 : PRE ==> POST.")

(equln "equiv " p " :" n>
       p " ~ " p " : " p " ==> " p "." n>
       (i proof)
       :ann
       "equiv lemma (\\n)"
       :doc
       "Syntax := equiv LEMMA (PARAM_1 : TYPE_1) ... (PARAM_N : TYPE_N) : MOD_1(MODARG_11, ..., MODARG_1n).PROC_1 ~ MOD_2(MODARG_21, ..., MODARG_2n).PROC_2 : PRE ==> POST.")

(equnln "equiv " p " :" n>
        p " ~ " p " :" n>
        p n>
        "==>" n>
        p "." n>
        (i proof)
        :ann
        "equiv lemma (\\n x2)"
        :doc
        "Syntax := equiv LEMMA (PARAM_1 : TYPE_1) ... (PARAM_N : TYPE_N) : MOD_1(MODARG_11, ..., MODARG_1n).PROC_1 ~ MOD_2(MODARG_21, ..., MODARG_2n).PROC_2 : PRE ==> POST.")

(ehol "ehoare " p " : " p " : " p " ==> " p "." n>
      (i proof)
      :ann
      "ehoare lemma"
      :doc
      "Syntax := ehoare LEMMA (PARAM_1 : TYPE_1) ... (PARAM_N : TYPE_N) : MOD(MODARG_1, ..., MODARG_N).PROC : PRE ==> POST.")

(eholn "ehoare " p " :" n>
       p " : " p " ==> " p "." n>
       (i proof)
       :ann
       "ehoare lemma (\\n)"
       :doc
       "Syntax := ehoare LEMMA (PARAM_1 : TYPE_1) ... (PARAM_N : TYPE_N) : MOD(MODARG_1, ..., MODARG_N).PROC : PRE ==> POST.")

(ehonln "ehoare " p " :" n>
        p " :" n>
        p n>
        "==>" n>
        p "." n>
        (i proof)
        :ann
        "ehoare lemma (\\n x2)"
        :doc
        "Syntax := ehoare LEMMA (PARAM_1 : TYPE_1) ... (PARAM_N : TYPE_N) : MOD(MODARG_1, ..., MODARG_N).PROC : PRE ==> POST.")

(fun "fun " p " => " q
     :ann
     "fun"
     :doc
     "Syntax := fun (PARAM_1 : TYPE_1) ... (PARAM_N : TYPE_N) => BODY")

(funn "fun " p " =>" n>
      q
      :ann
      "fun (\\n)"
      :doc
      "Syntax := fun (PARAM_1 : TYPE_1) ... (PARAM_N : TYPE_N) => BODY")

(for "forall " p ", " q
     :ann
     "forall"
     :doc
     "Syntax := forall (PARAM_1 : TYPE_1) ... (PARAM_N : TYPE_N), EXPR")

(forn "forall " p ", " n>
      q
      :ann
      "forall (\\n)"
      :doc
      "Syntax := forall (PARAM_1 : TYPE_1) ... (PARAM_N : TYPE_N), EXPR")

(exi "exists (" p "), " q
     :ann
     "exists"
     :doc
     "Syntax := exists (PARAM_1 : TYPE_1) ... (PARAM_N : TYPE_N), EXPR")

(exin "exists (" p ")," n>
      q
      :ann
      "exists (\\n)"
      :doc
      "Syntax := exists (PARAM_1 : TYPE_1) ... (PARAM_N : TYPE_N), EXPR")

(ifte "if " p " then " p " else " q
      :ann
      "if then else"
      :doc
      "Syntax := if BOOLEXPR then THENEXPR else ELSEEXPR")

(iften "if " p n>
       "then " p n>
       "else " q
       :ann
       "if then else (\\n)"
       :doc
       "Syntax := if BOOLEXPR then THENEXPR else ELSEEXPR")

(ge0 "0 <= " q
     :ann
     "0 <= _"
     :doc
     "Syntax := 0 <= EXPR")

(gt0 "0 < " q
     :ann
     "0 < _"
     :doc
     "Syntax := 0 < EXPR")

(rngii p " <= " p " <= " q
       :ann
       "range incl/incl"
       :doc
       "Syntax := LB_EXPR <= EXPR <= UB_EXPR")

(rngee p " < " p " < " q
       :ann
       "range excl/excl"
       :doc
       "Syntax := LB_EXPR < EXPR < UB_EXPR")

(rngie p " <= " p " < " q
       :ann
       "range incl/excl"
       :doc
       "Syntax := LB_EXPR <= EXPR < UB_EXPR")

(rngei p " < " p " <= " q
       :ann
       "range excl/incl"
       :doc
       "Syntax := LB_EXPR < EXPR <= UB_EXPR")

(letin "let " p " = " p " in " q
       :ann
       "let in"
       :doc
       "Syntax := let BINDVAR = BINDEXPR in EXPR")

(letinn "let " p " = " p n>
        "in " q
        :ann
        "let in (\\n)"
        :doc
        "Syntax := let BINDVAR = BINDEXPR in EXPR")


;;; Imperative specification
(pros "proc " p "(" p ") : " q
      :ann
      "proc signature"
      :doc
      "Syntax := proc PROC (PARAM_1 : TYPE_1, ..., PARAM_N : TYPE_N) : RESTYPE")

(prosr "proc " p "(" p ") : " p " { " q " }"
       :ann
       "proc signature (restr)"
       :doc
       "Syntax := proc PROC (PARAM_1 : TYPE_1, ..., PARAM_N : TYPE_N) : RESTYPE { PROCRESTR }")

(var "var " p " : " q
     :ann
     "var"
     :doc
     "Syntax := var VAR : TYPE")

(varp (i var) ";"
      :ann
      "var (;)"
      :doc
      "Syntax := var VAR : TYPE;")

(pro "proc " p "(" p ") = {" n>
     q n>
     "}" >
     :ann
     "proc spec"
     :doc
     "Syntax := proc PROC (PARAM_1 : TYPE_1, ..., PARAM_N : TYPE_N) = { [BODY] }")

(prot "proc " p "(" p ") : " p " = {" n>
      q n>
      "}" >
      :ann
      "proc spec (typed)"
      :doc
      "Syntax := proc PROC (PARAM_1 : TYPE_1, ..., PARAM_N : TYPE_N) : RESTYPE = { [BODY] }")

(prol "proc " p "(" p ") = { " q " }"
      :ann
      "proc spec (one-liner)"
      :doc
      "Syntax := proc PROC (PARAM_1 : TYPE_1, ..., PARAM_N : TYPE_N) = { [BODY] }")

(protl "proc " p "(" p ") : " p " = { " q " }"
       :ann
       "proc spec (typed + one-liner)"
       :doc
       "Syntax := proc PROC (PARAM_1 : TYPE_1, ..., PARAM_N : TYPE_N) : RESTYPE = { [BODY] }")

(proa "proc " p " = " q
      :ann
      "proc alias"
      :doc
      "Syntax := proc PROCALIAS = PROCORIG")

(modtyp "module type " p " = {" n>
        q n>
        "}." >
        :ann
        "module type"
        :doc
        "Syntax := module type MODTYPE = { [BODY] }.")

(modtypp "module type " p " (" p ") = {" n>
         q n>
         "}." >
         :ann
         "module type (param)"
         :doc
         "Syntax := module type MODTYPE (MODPARAM_1 : MODTYPE_1) ... (MODPARAM_N : MODTYPE_N) = { [BODY] }.")

(mod "module " p " = {" n>
     q n>
     "}." >
     :ann
     "module"
     :doc
     "Syntax := module MOD = { [BODY] }.")

(modp "module " p "(" p ") = {" n>
      q n>
      "}." >
      :ann
      "module (param)"
      :doc
      "Syntax := module MOD (MODPARAM_1 : MODTYPE_1) ... (MODPARAM_N : MODTYPE_N) = { [BODY] }.")

(modt "module " p " : " p " = {" n>
      q n>
      "}." >
      :ann
      "module (typed)"
      :doc
      "Syntax := module MOD : MODTYPE = { [BODY] }.")

(modpt "module " p " (" p ") : " p " = {" n>
       q n>
       "}." >
       :ann
       "module (typed + param)"
       :doc
       "Syntax := module MOD (MODPARAM_1 : MODTYPE_1) ... (MODPARAM_N : MODTYPE_N) : MODTYPE = { [BODY] }.")

(moda "module " p " = " q "."
      :ann
      "module alias"
      :doc
      "Syntax := module MODALIAS = MODORIG.")

(modap "module " p " = " p "(" q ")."
       :ann
       "module alias (param)"
       :doc
       "Syntax := module MODALIAS = MODORIG(MODARG_1, ..., MODARG_N).")


(if "if (" p ") {" n>
    q n>
    "}" >
    :ann
    "if spec"
    :doc
    "Syntax := if (BOOLEXPR) { [BODY] }")

(ifel "if (" p ") {" n>
      p n>
      "} else {" > n>
      q n>
      "}" >
      :ann
      "if else"
      :doc
      "Syntax := if (BOOLEXPR) { [BODY] } else { [ELSEBODY] }")

(ifeliel "if (" p ") {" n>
         p n>
         "} elif {" > n>
         p n>
         "} else {" > n>
         q n>
         "}" >
         :ann
         "if elif else"
         :doc
         "Syntax := if (BOOLEXPR) { [IFBODY] } elif { [ELIFBODY] } else { [ELSEBODY] }")

(while "while (" p ") {" n>
       q n>
       "}" >
       :ann
       "while spec"
       :doc
       "Syntax := while (BOOLEXPR) { [BODY] }")

(ass p "<-" q ";"
     :ann
     "var assign"
     :doc
     "Syntax := VAR <- EXPR;")

(cals p "<@" q ";"
      :ann
      "proc call"
      :doc
      "Syntax := VAR <@ MOD(MODARG_1, ..., MODARG_N).PROC(ARG_1, ..., ARG_N);")

(sam p "<$" q ";"
     :ann
     "sample"
     :doc
     "Syntax := VAR <$ DISTREXPR;")


;;; Tactics
;; Ambient
(smt "smt(" q ")"
     :ann
     "smt limit"
     :doc
     "Syntax := smt(Lemma_1|@Theory_1 ... Lemma_N|@Theory_N)")

(movi "move=> " q
      :ann
      "move (intro)"
      :doc
      "Syntax :=  move=> INTROPAT_1 ... INTROPAT_N")

(movg "move: " q
      :ann
      "move (gen)"
      :doc
      "Syntax :=  move: GENTERM_1 ... GENTERM_N")

(pos "pose " p " := " q
     :ann
     "pose"
     :doc
     "Syntax := pose VAR := EXPR")

(hav "have " p ": " q
     :ann
     "have"
     :doc
     "Syntax := have INTROPAT_1 ... INTROPAT_N : BOOLEXPR")

(havby "have " p ": " p " by " q
       :ann
       "have by"
       :doc
       "Syntax := have INTROPAT_1 ... INTROPAT_N : BOOLEXPR by PROOFSENT")

(havr "have ->: " q
      :ann
      "have -> (rewr right)"
      :doc
      "Syntax := have ->: BOOLEXPR")

(havl "have <-: " q
      :ann
      "have <- (rewr left)"
      :doc
      "Syntax := have <-: BOOLEXPR")

(havs "have /#: " q
      :ann
      "have /# (smt)"
      :doc
      "Syntax := have /#: BOOLEXPR")

(app "apply " q
     :ann
     "apply"
     :doc
     "Syntax := apply PROOFTERM
Syntax := apply /PROOFTERM_1 ... /PROOFTERM_N")

(appin "apply " p " in " q
       :ann
       "apply in"
       :doc
       "Syntax := apply PROOFTERM in HYPOTHESIS")

(rew "rewrite " q
     :ann
     "rewrite"
     :doc
     "Syntax := rewrite REWRPAT_1 ... REWRPAT_N")

(rewin "rewrite " p " in " q
       :ann
       "Syntax := rewrite REWRPAT_1 ... REWRPAT_N in HYPOTHESIS")

(rewl "rewrite (: " q ")"
      :ann
      "rewrite literal"
      :doc
      "Syntax := rewrite (: REWRTERM)")

(rewle "rewrite (: " p " = " q ")"
       :ann
       "rewrite literal eq"
       :doc
       "Syntax := rewrite (: EXPR_1 = EXPR_2)")


;; Program
(proc "proc (" q ")"
      :ann
      "proc tactic"
      :doc
      "Syntax := proc (INVARIANT)")

(procub "proc (" p ") (" q ")"
        :ann
        "proc tactic up to bad"
        :doc
        "Syntax := proc (BADEVENT) (INVARIANT-UP-TO-BAD)")

(procube "proc (" p ") (" p ") (" q ")"
         :ann
         "proc tactic up to + after bad"
         :doc
         "Syntax := proc (BADEVENT) (INVARIANT-UP-TO-BAD) (INVARIANT-AFTER-BAD)")

(seq "seq " p " " p " : (" q ")"
     :ann
     "seq (pRHL)"
     :doc
     "Syntax := seq CODEPOS-LEFT CODEPOS-RIGHT : CONDITION-AT-CUT")

(seqh "seq " p " : (" q ")"
      :ann
      "seq (HL)"
      :doc
      "Syntax := seq CODEPOS : CONDITION-AT-CUT")

(seqp "seq " p " : (" p ") (" p ") (" p ") (" p ") (" p ") (" q ")"
      :ann
      "seq (pHL)"
      :doc
      "Syntax := seq CODEPOS : CONDITION-AT-CUT PROB-COND-AT-CUT PROB-POST-WHEN-COND PROB-NOT-COND-AT-CUT PROB-POST-WHEN-NOT-COND INVARIANT-AT-CUT")

(sp "sp " q
    :ann
    "sp"
    :doc
    "Syntax (pRHL) := sp CODEPOS-LEFT CODEPOS-RIGHT
Syntax (HL/pHL) := sp CODEPOS")

(sp1 "sp{1} " q
     :ann
     "sp left program"
     :doc
     "Syntax := sp{1} CODEPOS")

(sp2 "sp{2} " q
     :ann
     "sp right program"
     :doc
     "Syntax := sp{2} CODEPOS")

(wp "wp " q
    :ann
    "wp"
    :doc
    "Syntax (pRHL) := wp CODEPOS-LEFT CODEPOS-RIGHT
Syntax (HL/pHL) := wp CODEPOS")

(wp1 "wp{1} " q
     :ann
     "wp left program"
     :doc
     "Syntax := wp{1} CODEPOS")

(wp2 "wp{2} " q
     :ann
     "wp right program"
     :doc
     "Syntax := wp{2} CODEPOS")

(rnd "rnd " q
     :ann
     "rnd"
     :doc
     "Syntax (pRHL) := rnd FUN INVFUN
Syntax (HL) := rnd
Syntax (pHL) := rnd EVENT")

(rnd1 "rnd{1} " q
      :ann
      "rnd left program"
      :doc
      "Syntax := rnd{1}")

(rnd2 "rnd{2} " q
      :ann
      "rnd right program"
      :doc
      "Syntax := rnd{2}")

(ifd "if"
     :ann
     "if tactic"
     :doc
     "Syntax := if")

(if1 "if{1}"
     :ann
     "if tactic left program"
     :doc
     "Syntax := if{1}")

(if2 "if{2}"
     :ann
     "if tactic right program"
     :doc
     "Syntax := if{2}")

(whi "while (" q ")"
     :ann
     "while tactic (pRHL/HL)"
     :doc
     "Syntax := while (INVARIANT)")

(whip "while (" p ") (" p ") (" p ") (" q ")"
      :ann
      "while tactic (pHL)"
      :doc
      "Syntax := while (INVARIANT) (TERMINATION-VARIANT) (UPPERBOUND-TERM-VARIANT) (PROB-TERM-VARIANT-DECREASE)")

(whi1 "while{1} (" p ") (" q ")"
      :ann
      "while tactic left program"
      :doc
      "Syntax := while{1} (INVARIANT) (TERMINATION-VARIANT)")

(whi2 "while{2} (" p ") (" q ")"
      :ann
      "while tactic right program"
      :doc
      "Syntax := while{2} (INVARIANT) (TERMINATION-VARIANT)")

(cal "call (_: " q ")"
     :ann
     "call"
     :doc
     "Syntax := call (_: INVARIANT)")

(cal1 "call{1} (_: " q ")"
      :ann
      "call left program"
      :doc
      "Syntax := call{1} (_: INVARIANT)")

(cal2 "call{2} (_: " q ")"
      :ann
      "call right program"
      :doc
      "Syntax := call{2} (_: INVARIANT)")

(calt "call (_: true)"
      :ann
      "call true"
      :doc
      "Syntax := call (_: true)")

(cal1t "call{1} (_: true)"
       :ann
       "call true left program"
       :doc
       "Syntax := call{1} (_: true)")

(cal2t "call{2} (_: true)"
       :ann
       "call true right program"
       :doc
       "Syntax := call{2} (_: true)")

(calc "call (_: " p " ==> " q ")"
      :ann
      "call contract"
      :doc
      "Syntax := call (_: PRE ==> POST)")

(cal1c "call{1} (_: " p " ==> " q ")"
       :ann
       "call contract left program"
       :doc
       "Syntax := call{1} (_: PRE ==> POST)")

(cal2c "call{2} (_: " p " ==> " q ")"
       :ann
       "call contract right program"
       :doc
       "Syntax := call{2} (_: PRE ==> POST)")

(calpt "call (" q ")"
       :ann
       "call proofterm"
       :doc
       "Syntax := call (PROOFTERM)")

(cal1pt "call{1} (" q ")"
        :ann
        "call proofterm left program"
        :doc
        "Syntax := call{1} (PROOFTERM)")

(cal2pt "call{2} (" q ")"
        :ann
        "call proofterm right program"
        :doc
        "Syntax := call{2} (PROOFTERM)")

(calub "call (_: " p ", " q ")"
       :ann
       "call up to bad"
       :doc
       "Syntax := call (_: BADEVENT, INVARIANT-UP-TO-BAD)")

(calube "call (_: " p ", " p ", " q ")"
        :ann
        "call up to + after bad"
        :doc
        "Syntax := call (_: BADEVENT, INVARIANT-UP-TO-BAD, INVARIANT-AFTER-BAD)")

(eca "ecall (" q ")"
     :ann
     "ecall"
     :doc
     "Syntax := ecall (PROOFTERM)")

(eca1 "ecall{1} (" q ")"
      :ann
      "ecall left program"
      :doc
      "Syntax := ecall{1} (PROOFTERM)")

(eca2 "ecall{2} (" q ")"
      :ann
      "ecall right program"
      :doc
      "Syntax := ecall{2} (PROOFTERM)")

(swa "swap " p " " q
     :ann
     "swap (HL/pHL)"
     :doc
     "Syntax := swap CODEPOS MOVE-AMOUNT")

(swa1 "swap{1} " p " " q
      :ann
      "swap left program"
      :doc
      "Syntax := swap{1} CODEPOS MOVE-AMOUNT")

(swa2 "swap{2} " p " " q
      :ann
      "swap right program"
      :doc
      "Syntax := swap{2} CODEPOS MOVE-AMOUNT")

(swabl "swap [" p ".." p "] " q
       :ann
       "swap block (HL/pHL)"
       :doc
       "Syntax := swap [CODEPOS-BEGIN .. CODEPOS-END] MOVE-AMOUNT")

(swa1bl "swap{1} [" p ".." p "] " q
        :ann
        "swap block left program"
        :doc
        "Syntax := swap{1} [CODEPOS-BEGIN .. CODEPOS-END] MOVE-AMOUNT")

(swa2bl "swap{2} [" p ".." p "] " q
        :ann
        "swap block right program"
        :doc
        "Syntax := swap{2} [CODEPOS-BEGIN .. CODEPOS-END] MOVE-AMOUNT")

(swas "swap " p " " p " " q
      :ann
      "swap blocks (HL/pHL)"
      :doc
      "Syntax := swap CODEPOS-BEGIN CODEPOS-MID CODEPOS-END")

(swa1s "swap{1} " p " " p " " q
       :ann
       "swap blocks left program"
       :doc
       "Syntax := swap{1} CODEPOS-BEGIN CODEPOS-MID CODEPOS-END")

(swa2s "swap{2} " p " " p " " q
       :ann
       "swap blocks right program"
       :doc
       "Syntax := swap CODEPOS-BEGIN CODEPOS-MID CODEPOS-END")

(inl "inline " q
     :ann
     "inline"
     :doc
     "Syntax := inline CODEPOS-PROC
Syntax := inline MOD_1.PROC_1, ..., MOD_N.PROC_N")

(inl1 "inline{1} " q
      :ann
      "inline left program"
      :doc
      "Syntax := inline{1} CODEPOS-PROC
Syntax := inline{1} MOD_1.PROC_1, ..., MOD_N.PROC_N")

(inl2 "inline{2} " q
      :ann
      "inline right program"
      :doc
      "Syntax := inline{2} CODEPOS-PROC
Syntax := inline{2} MOD_1.PROC_1 ... MOD_N.PROC_N")

(inls "inline *"
      :ann
      "inline all"
      :doc
      "Syntax := inline *")

(inl1s "inline{1} *"
       :ann
       "inline all left program"
       :doc
       "Syntax := inline{1} *")

(inl2s "inline{2} *"
       :ann
       "inline all right program"
       :doc
       "Syntax := inline{2} *")

(inlo "inline (" p ") " q
      :ann
      "inline occs"
      :doc
      "Syntax := inline (CODEPOS_1 ... CODEPOS_N) MOD.PROC")

(inl1o "inline{1} (" p ") " q
       :ann
       "inline occs left program"
       :doc
       "Syntax := inline{1} (CODEPOS_1 ... CODEPOS_N) MOD.PROC")

(inl2o "inline{2} (" p ") " q
       :ann
       "inline occs right program"
       :doc
       "Syntax := inline{2} (CODEPOS_1 ... CODEPOS_N) MOD.PROC")

(out "outline{" p "} " p " ~ " q
     :ann
     "outline"
     :doc
     "Syntax := outline{SIDE} CODEPOS ~ MOD.PROC")

(outbl "outline{" p "} [" p ".." p "] ~ " q
       :ann
       "outline block"
       :doc
       "Syntax := outline{SIDE} [CODEPOS-BEGIN .. CODEPOS-END] ~ MOD.PROC")

(outc "outline{" p "} " p " by { " q " }"
      :ann
      "outline code"
      :doc
      "Syntax := outline{SIDE} CODEPOS by { PROGSTAT_1; ...; PROGSTAT_N; }")

(outblc "outline{" p "} [" p ".." p "] by { " q " }"
        :ann
        "outline block code"
        :doc
        "Syntax := outline{SIDE} [CODEPOS-BEGIN .. CODEPOS-END] by { PROGSTAT_1; ...; PROGSTAT_N; }")

(rcot "rcondt " q
      :ann
      "rcondt"
      :doc
      "Syntax := rcondt CODEPOS-IF-OR-WHILE")

(rcot1 "rcondt{1} " q
       :ann
       "rcondt left program"
       :doc
       "Syntax := rcondt{1} CODEPOS-IF-OR-WHILE")

(rcot2 "rcondt{2} " q
       :ann
       "rcondt right program"
       :doc
       "Syntax := rcondt{2} CODEPOS-IF-OR-WHILE")

(rcof "rcondf " q
      :ann
      "rcondf"
      :doc
      "Syntax := rcondf CODEPOS-IF-OR-WHILE")

(rcof1 "rcondf{1} " q
       :ann
       "rcondf left program"
       :doc
       "Syntax := rcondf{1} CODEPOS-IF-OR-WHILE")

(rcof2 "rcondf{2} " q
       :ann
       "rcondf right program"
       :doc
       "Syntax := rcondf{2} CODEPOS-IF-OR-WHILE")

(unr "unroll " q
     :ann
     "unroll"
     :doc
     "Syntax := unroll CODEPOS-WHILE")

(unr1 "unroll{1} " q
      :ann
      "unroll left program"
      :doc
      "Syntax := unroll{1} CODEPOS-WHILE")

(unr2 "unroll{2} " q
      :ann
      "unroll right program"
      :doc
      "Syntax := unroll{2} CODEPOS-WHILE")

(splwhi "splitwhile " p " : (" q ")"
        :ann
        "splitwhile"
        :doc
        "Syntax := splitwhile CODEPOS-WHILE : (CONDITION-WHILE)")

(splwhi1 "splitwhile{1} " p " : (" q ")"
         :ann
         "splitwhile left program"
         :doc
         "Syntax := splitwhile{1} CODEPOS-WHILE : (CONDITION-WHILE)")

(splwhi2 "splitwhile{2} " p " : (" q ")"
         :ann
         "splitwhile right program"
         :doc
         "Syntax := splitwhile{2} CODEPOS-WHILE : (CONDITION-WHILE)")

(fis "fission " p "!" p " @ " p ", " q
     :ann
     "fission"
     :doc
     "Syntax := fission CODEPOS-WHILE ! NUM-LINES-BEFORE-WHILE @ CODEPOS-END-FIRST, CODEPOS-END-SECOND")

(fis1 "fission{1} " p "!" p " @ " p ", " q
      :ann
      "fission left program"
      :doc
      "Syntax := fission{1} CODEPOS-WHILE ! NUM-LINES-BEFORE-WHILE @ CODEPOS-END-FIRST CODEPOS-END-SECOND")

(fis2 "fission{2} " p "!" p " @ " p ", " q
      :ann
      "fission right program"
      :doc
      "Syntax := fission{2} CODEPOS-WHILE ! NUM-LINES-BEFORE-WHILE @ CODEPOS-END-FIRST CODEPOS-END-SECOND")

(fus "fusion " p "!" p " @ " p ", " q
     :ann
     "fusion"
     :doc
     "Syntax := fusion CODEPOS-WHILE ! NUM-LINES-BEFORE-WHILE @ CODEPOS-END-FIRST, CODEPOS-END-SECOND")

(fus1 "fusion{1} " p "!" p " @ " p ", " q
      :ann
      "fusion left program"
      :doc
      "Syntax := fusion{1} CODEPOS-WHILE ! NUM-LINES-BEFORE-WHILE @ CODEPOS-END-FIRST, CODEPOS-END-SECOND")

(fus2 "fusion{2} " p "!" p " @ " p ", " q
      :ann
      "fusion right program"
      :doc
      "Syntax := fusion{2} CODEPOS-WHILE ! NUM-LINES-BEFORE-WHILE @ CODEPOS-END-FIRST, CODEPOS-END-SECOND")

(ali "alias " p " with " q
     :ann
     "alias"
     :doc
     "Syntax := alias CODEPOS-ASSIGNMENT with ALIAS")

(ali1 "alias{1} " p " with " q
      :ann
      "alias left program"
      :doc
      "Syntax := alias{1} CODEPOS-ASSIGNMENT with ALIAS")

(ali2 "alias{2} " p " with " q
      :ann
      "alias right program"
      :doc
      "Syntax := alias{2} CODEPOS-ASSIGNMENT with ALIAS")

(alie "alias " p " " p " = " q
      :ann
      "alias expr"
      :doc
      "Syntax := alias CODEPOS ALIAS EXPR")

(ali1e "alias{1} " p " " p " = " q
       :ann
       "alias expr left program"
       :doc
       "Syntax := alias{1} CODEPOS ALIAS EXPR")

(ali2e "alias{2} " p " " p " = " q
       :ann
       "alias expr right program"
       :doc
       "Syntax := alias{2} CODEPOS ALIAS EXPR")

(cfo "cfold " p " " q
     :ann
     "cfold"
     :doc
     "Syntax := cfold CODEPOS-ASSIGNMENT CODEPOS-END")

(cfo1 "cfold{1} " p " " q
      :ann
      "cfold left program"
      :doc
      "Syntax := cfold{1} CODEPOS-ASSIGNMENT CODEPOS-END")

(cfo2 "cfold{2} " p " " q
      :ann
      "cfold right program"
      :doc
      "Syntax := cfold{2} CODEPOS-ASSIGNMENT CODEPOS-END")

(kil "kill " p " ! " q
     :ann
     "kill"
     :doc
     "Syntax := kill CODEPOS-START ! NUM-LINES")

(kil1 "kill{1} " p " ! " q
      :ann
      "kill left program"
      :doc
      "Syntax := kill{1} CODEPOS-START ! NUM-LINES")

(kil2 "kill{2} " p " ! " q
      :ann
      "kill right program"
      :doc
      "Syntax := kill{2} CODEPOS-START ! NUM-LINES")

(tra "transitivity " p " (" p " ==> " p ") (" p " ==> " q ")"
     :ann
     "transitivity"
     :doc
     "Syntax := transitivity MOD.PROC (PRE-LEFT ==> POST-LEFT) (PRE-RIGHT ==> POST-RIGHT)")

(trac "transitivity{" p "} { " p " } " p " (" p " ==> " p ") (" p " ==> " q ")"
      :ann
      "transitivity code"
      :doc
      "Syntax := transitivity{SIDE} { PROGSTAT_1; ...; PROGSTAT_N; } (PRE-LEFT ==> POST-LEFT) (PRE-RIGHT ==> POST-RIGHT)")

(cons "conseq (_: " p " ==> " q ")"
      :ann
      "conseq"
      :doc
      "Syntax := conseq (_: PRE ==> POST)")

(conspt "conseq (" q ")"
        :ann
        "conseq proofterm"
        :doc
        "Syntax := conseq (PROOFTERM)")

(conscr "conseq />"
        :ann
        "conseq crush"
        :doc
        "Syntax := conseq />")

(consehh "conseq (_: " p " ==> " p ") (_: " p " ==> " p ") (_: " p " ==> " q ")"
         :ann
         "conseq equiv hoare hoare"
         :doc
         "Syntax := conseq (_: PRE-EQUIV ==> POST-EQUIV) (_: PRE-HOARE-LEFT ==> POST-HOARE-LEFT) (_: PRE-HOARE-RIGHT ==> POST-HOARE-RIGHT)")

(consph "conseq (_: " p " ==> " p ": " p ") (_: " p " ==> " q ")"
         :ann
         "conseq phoare hoare"
         :doc
         "Syntax := conseq (_: PRE-PHOARE ==> POST-PHOARE : PROB-BND-OR-EQ) (_: PRE-HOARE ==> POST-HOARE)")


(conseh "conseq (" p ") (_: " p " ==> " q ")"
        :ann
        "conseq equiv hoare"
        :doc
        "Syntax := conseq (PROOFTERM-EQUIV) (_: PRE-HOARE ==> POST-HOARE)")

(bye "byequiv (_: " p " ==> " q ")"
     :ann
     "byequiv"
     :doc
     "Syntax := byequiv (_: PRE ==> POST)")

(byept "byequiv (" q ")"
       :ann
       "byequiv proofterm"
       :doc
       "Syntax := byequiv (PROOFTERM)")

(byeub "byequiv (_: " p " ==> " p ") : " q
       :ann
       "byequiv up to bad"
       :doc
       "Syntax := byequiv (_: PRE ==> POST) : BADEVENT")

(byeubpt "byequiv (" p ") : " q
         :ann
         "byequiv up to bad proofterm"
         :doc
         "Syntax := byequiv (PROOFTERM) : BADEVENT")

(byp "byphoare (_: " p " ==> " q ")"
     :ann
     "byphoare"
     :doc
     "Syntax := byphoare (_: PRE ==> POST)")

(byppt "byphoare (" q ")"
       :ann
       "byphoare proofterm"
       :doc
       "Syntax := byphoare (PROOFTERM)")

(bypr "bypr (" p ") (" q ")"
      :ann
      "bypr"
      :doc
      "Syntax := bypr (EXPR-LEFT) (EXPR-RIGHT)")

(exis "exists* " q
      :ann
      "exists*"
      :doc
      "Syntax := exists* EXPR_1, ..., EXPR_N")

(elis "elim*"
      :ann
      "elim*"
      :doc
      "Syntax := elim*")

(exli "exlim " q
      :ann
      "exlim"
      :doc
      "Syntax := exlim EXPR_1, ..., EXPR_N")

(phosplj "phoare split " p " " p " " q
         :ann
         "phoare split junctions"
         :doc
         "Syntax := phoare split PROB-POST-A PROB-POST-B PROB-POST-A-AND/OR-B")

(phospln "phoare split ! " p " " q
         :ann
         "phoare split negation"
         :doc
         "Syntax := phoare split PROB-POST-TRUE PROB-POST-NEG")

(phosple "phoare split " p " " p " : " q
         :ann
         "phoare split event"
         :doc
         "Syntax := phoare split PROB-POST-AND-A PROB-POST-AND-NOT-A")

(sim "sim : (" q ")"
     :ann
     "sim"
     :doc
     "Syntax := sim : (VAR-EQUALITIES)")

(simi "sim / " p " : (" q ")"
      :ann
      "sim invariant"
      :doc
      "Syntax := sim / INVARIANT-GLOB-VARS : (VAR-EQUALITIES)")

(simpi "sim " p " / " p " : (" q ")"
       :ann
       "sim procs invariant"
       :doc
       "Syntax := sim (MOD_11.PROC_11 ~ MOD_12.PROC_12 : GLOB-VAR-EQUALITIES_1) ... (MOD_N1.PROC_N1 ~ MOD_N2.PROC_N2 : GLOB-VAR-EQUALITIES_N) / INVARIANT-GLOB-VARS : (VAR-EQUALITIES)")

(fel "fel " p " (" p ") (" p ") (" p ") (" p ") [" p "] (" q ")"
     :ann
     "fel (failure event lemma)"
     :doc
     "Syntax := fel CODEPOS-INIT-END (COUNTER-EXPR) (UPPERBOUND-STEP-FUNCTION) (UPPERBOUND-COUNTER) (BADEVENT) [ MOD_1.PROC_1 : PRE_1; ...; MOD_N.PROC_N : PRE_N] INVARIANT")

(rewequ "rewrite equiv [{" p "} " q "]"
        :ann
        "rewrite equiv"
        :doc
        "Syntax := rewrite equiv [{SIDE} CODEPOS-PROC PROOFTERM-EQUIV]")

(rewequrv "rewrite equiv [{" p "} " p " (" p " :@ " q ")]"
          :ann
          "rewrite equiv"
          :doc
          "Syntax := rewrite equiv [{SIDE} CODEPOS-PROC PROOFTERM-EQUIV (ARG_1, ..., ARG_N :@ RETURN-VAR)]")

(proccha "proc change " p " : " q
         :ann
         "proc change"
         :doc
         "Syntax := proc change CODEPOS : EXPR")

(proccha1 "proc change{1} " p " : " q
          :ann
          "proc change left program"
          :doc
          "Syntax := proc change{1} CODEPOS : EXPR")

(proccha2 "proc change{2} " p " : " q
          :ann
          "proc change right program"
          :doc
          "Syntax := proc change{2} CODEPOS : EXPR")

(procrew "proc rewrite " q
         :ann
         "proc rewrite"
         :doc
         "Syntax := proc rewrite CODEPOS : PROOFTERM")

(procrew1 "proc rewrite{1} " q
          :ann
          "proc rewrite left program"
          :doc
          "Syntax := proc rewrite{1} CODEPOS : REWRPAT")

(procrew2 "proc rewrite{2} " q
          :ann
          "proc rewrite right program"
          :doc
          "Syntax := proc rewrite{2} CODEPOS : REWRPAT")
