;; easycrypt-info.eld
;; Tempel informative templates for easycrypt mode

easycrypt-mode

;; Meta
(requireinfo "require " (p "Theory1, ..., TheoryN") ".")
(importinfo "import " (p "Theory1, ..., TheoryN") ".")

;; TODO: Clone info

;; Functional specification
(typeinfo "type " (p "Name") " = " (p "Def") ".")

(opinfo "op " (p "Name") " " (p "(Param1 : Type1) ... (ParamN : TypeN)") " : " (p "Type") " = " (p "Def") ".")
(opasinfo "op " (p "Name (Op)") " " (p "(Param1 : Type1) ... (ParamN : TypeN)") " : { " (p "Type") " | " (p "AxiomStatement") " } as " (p "Name (Axiom)") ".")
(constinfo "const "  (p "Name") " (" (p "Param") " : " (p "Type") ") : " (p "Type") " = " (p "Def") ".")
(abbrevinfo "abbrev "  (p "Name") " " (p "(Param1 : Type1) ... (ParamN : TypeN)") " : " (p "Type") " = " (p "Def") ".")

(theoryinfo "theory " (p "Name" thid)  "." n>
            (p "Body") n>
            "end " (s thid) "." >)
(sectioninfo "section" (p "Name" secid) "." n>
           (p "Body") >
           "end section " (s secid) "." >)

(declaremoduleinfo "declare module " (p "Name")  " <: " (p "ModType")  "{ " (p "+/- Mod1(ModArg11, ..., ModArg1N), ..., +/- ModN(ModArgN1, ..., ModArgNN)") " }.")

(Prinfo "Pr[" (p "Mod.Proc(Arg1, ..., ArgN)") " @ " (p "Memory") " : " (p "Event") "]")

(hoareinfo "hoare[" (p "Mod.Proc") " : " (p "Pre") " ==> " (p "Post") "]")
(phoareinfo "phoare[" (p "Mod.Proc") " : " (p "Pre") " ==> " (p "Post") "] = " (p "Prob"))
(equivinfo "equiv[" (p "Mod1.Proc1") " ~ " (p "Mod2.Proc2") " : " (p "Pre") " ==> " (p "Post") "]")
(ehoareinfo "ehoare[" (p "Mod.Proc") " : " (p "Pre") " ==> " (p "Post") "]")

(axiominfo "axiom " (p "Name") " " (p "(Param1 : Type1) ... (ParamN : TypeN)") " : " (p "Statement") ".")

(proofinfo "proof." > n>
           (p "Proof") n>
           "qed." >)

(lemmainfo "lemma " (p "Name") " " (p "(Param1 : Type1) ... (ParamN : TypeN)") " : " (p "Statement") "." n>
           (i proofinfo))
(lemmallinfo "lemma " (p "Name") " : islossless " (p "Mod.Proc") "." n>
             (i proofinfo))

(hoarelemmainfo "hoare " (p "Name") " " (p "(Param1 : Type1) ... (ParamN : TypeN)") " : " (p "Mod.Proc") " : " (p "Pre") " ==> " (p "Post") "." n>
                (i proofinfo))
(equivlemmainfo "equiv " (p "Name") " " (p "(Param1 : Type1) ... (ParamN : TypeN)") " : " (p "Mod1.Proc1") " ~ " (p "Mod2.Proc2") " : " (p "Pre") " ==> " (p "Post") "." n>
                (i proofinfo))
(ehoarelemmainfo "ehoare " (p "Name") " " (p "(Param1 : Type1) ... (ParamN : TypeN)") " : " (p "Mod.Proc") " : " (p "Pre") " ==> " (p "Post") "." n>
                 (i proofinfo))

;; Imperative specification
(procsiginfo "proc " (p "Name") "(" (p "Param1 : Type1, ..., ParamN : TypeN") ") : " (p "Type") " { " (p "ModParam1.Proc11, ... ModParam1.Proc1N, ..., ModParamN.ProcNN") " }")

(varinfo "var " (p "Name") " : " (p "Type"))
(varpinfo (i varinfo) ";")

(procinfo "proc " (p "Name") "(" (p "Param1 : Type1, ..., ParamN : TypeN") ") : " (p "Type") " = {" n>
          (i varpinfo) n>
          (p "Body") n>
          "}" >)
(procaliasnfo "proc " (p "Name") " = " (p "Mod.Proc"))

(moduletypeinfo "module type " (p "Name") " " (p "(ModParam1 : ModType1) ... (ModParamN : ModTypeN)") " = {" n>
                (i procsiginfo) n>
                "}." >)
(moduleinfo "module " (p "Name") " "  (p "(ModParam1 : ModType1) ... (ModParamN : ModTypeN)") " : " (p "ModType") " = {" n>
            (i varinfo) n>
            (i procinfo) n>
            "}." >)
(modulealiasinfo "module " (p "Name") " = " (p "Mod(ModArg1, ..., ModArgN)") ".")

;; Tactics
(smtinfo "smt(" (p "Lemma1|@Theory1 ... LemmaN|@TheoryN") ")")

(poseinfo "pose " (p "Name") " := " (p "Expr"))
(haveinfo "have " (p "IntroPattern") ": " (p "Statement"))

(proctinfo "proc (" (p "Invariant") ")")
(proctupbadinfo "proc (" (p "BadEvent") ") (" (p "InvariantUptoBad") ")")
(proctupbadextinfo "proc (" (p "BadEvent") ") (" (p "InvariantUptoBad") ") (" (p "InvariantAfterBad") ")")

(seqinfo "seq " (p "CodePosCutLeft") " " (p "CodePosCutRight") " :  (" (p "ConditionAtCut") ")")
(seqhoainfo "seq " (p "CodePosCut") " :  (" (p "ConditionAtCut") ")")
(seqphinfo "seq " (p "CodePosCut") " : (" (p "Event") ") (" (p "ProbEventTrueAtCut") ") (" (p "ProbPostTrueWhenEventTrue") ") (" (p "ProbEventFalseAtCut") ") (" (p "ProbPostTrueWhenEventFalse") ") (" (p "InvariantAtCut") ")")

(spinfo "sp " (p "CodePosLeft") " " (p "CodePosRight"))
(wpinfo "wp " (p "CodePosLeft") " " (p "CodePosRight"))

(rndinfo "rnd " (p "Fun") " " (p "InverseFun"))
(rndinvinfo "rnd " (p "InvolutiveFun"))

(whileinfo "while " (p "Invariant"))
(whilephinfo "while " (p "Invariant") (p "TerminationVariant") (p "UpperBndTermVar") (p "ProbTermVarDecrease")) ; TODO: ask PY if correct
(while1info "while{1} " (p "Invariant") (p "TerminationVariant")) ; TODO: ask PY if this is correct
(while2info "while{2} " (p "Invariant") (p "TerminationVariant"))

(callinfo "call (_: " (p "Invariant") ")")
(callcontinfo "call (_: " (p "Pre") " ==> " (p "Post") ")")
(callptinfo "call (" (p "Proofterm") ")")
(callubinfo "call (_: " (p "BadEvent") ", " (p "InvariantUptoBad") ")")
(callubeinfo "call (_: " (p "BadEvent") ", " (p "InvariantUptoBad") ", " (p "InvariantAfterBad") ")")

(ecallinfo "ecall (" (p "Proofterm") ")")

(swapinfo "swap " (p "CodePos|CodePosBlock") " " (p "(-)MoveAmount"))
(swapsinfo "swap " (p "CodePosBegin") " " (p "CodePosMid") " " (p "CodePosEnd"))

(inlineinfo "inline " (p "Mod1.Proc1, ..., ModN.ProcN | CodePosProc"))
(inlineoinfo "inline (" (p "CodePosOccur1 ... CodePosOccurN") ") " (p "Mod.Proc"))

(outlineinfo "outline{" (p "Side (1/2)") "} " (p "CodePos|CodePosBlock") " ~ " (p "Mod.Proc"))
(outlinecodeinfo "outline{" (p "Side (1/2)") "} " (p "CodePos|CodePosBlock") " by {" (p " ProgStatement1; ... ProgStatementN;") " }")

(rcondtinfo "rcondt " (p "CodePosIf|CodePosWhile"))
(rcondfinfo "rcondf " (p "CodePosIf|CodePosWhile"))

(unrollinfo "unroll " (p "CodePosWhile"))

(splitwhileinfo "splitwhile " (p "CodePosWhile") " : (" (p "WhileCondition") ")")

(fissioninfo "fission " (p "CodePosWhile") "!" (p "NumLinesBeforeWhile") " @ " (p "CodePosEndBlock1") ", " (p "CodePosEndBlock2"))
(fusioninfo "fusion " (p "CodePosWhile") "!" (p "NumLinesBeforeWhile") " @ " (p "CodePosEndBlock1") ", " (p "CodePosEndBlock2"))

(aliasinfo "alias " (p "CodePosAssignment") " with " (p "VarName"))
(aliaseinfo "alias " (p "CodePosAssignment") " " (p "VarName") " = " (p "Expr"))

(cfoldinfo "cfold " (p "CodePosAssignment") " " (p "CodePosEndBlock"))

(killinfo "kill " (p "CodePosStartBlock") " ! " (p "LengthBlock"))

(transivityinfo "transitivity " (p "Mod.Proc") " (" (p "PreLeft") " ==> " (p "PostLeft") ") (" (p "PreRight") " ==> " (p "PostRight") ")")
(transivitycodeinfo "transitivity{" (p "Side (1/2)") "} { " (p "ProgStatement1; ...; ProgStatementN;") " } (" (p "PreLeft") " ==> " (p "PostLeft") ") (" (p "PreRight") " ==> " (p "PostRight") ")")

(conseqinfo "conseq (_: " (p "Pre") " ==> " (p "Post") ")")
(conseqptinfo "conseq (" (p "Proofterm") ")")
(conseqeqvhoahoainfo "conseq (_: " (p "PreEquiv") " ==> " (p "PostEquiv") ") (_: " (p "PreHoareLeft") " ==> " (p "PostHoareLeft") ") (_: " (p "PreHoareRight") " ==> " (p "PostHoareRight") ")")
(conseqphhoahoainfo "conseq (_: " (p "PrePhoare") " ==> " (p "PostPhoare") ": " (p "ProbBnd|ProbEq (ex: =1%r)") ") (_: " (p "PreHoare") " ==> " (p "PostHoare") ")")
(conseqeqvhoainfo "conseq (" (p "ProoftermEquiv") ") (_: " (p "PreHoare") " ==> " (p "PostHoare") ")")

(byequivinfo "byequiv (_: " (p "Pre") " ==> " (p "Post") ")")
(byequivptinfo "byequiv (" (p "ProoftermEquiv") ")")
(byequivupbadinfo "byequiv (_: " (p "Pre") " ==> " (p "Post") ") : " (p "BadEvent"))
(byequivupbadptinfo "byequiv (" (p "ProoftermEquiv") ") : " (p "BadEvent"))

(byphoareinfo "byphoare (_: " (p "Pre") " ==> " (p "Post") ")")
(byphoareptinfo "byphoare (" (p "ProoftermPhoare") ")")

(bypr "bypr (" (p "ExprLeft") ") (" (p "ExprRight") ")")

(existssinfo "exists* " (p "Expr1, ..., ExprN"))
(exliminfo "exlim " (p "Expr1, ..., ExprN"))

(phoaresplitjuncinfo "phoare split " (p "ProbPostClause1") " " (p "ProbPostClause2") " " (p "ProbPostDualJunction"))
(phoaresplitneginfo "phoare split ! " (p "ProbPostTrue") " " (p "ProbPostNegation"))

(siminfo "sim : (" (p "VarEqualities") ")")
(siminvinfo "sim / " (p "InvariantGlobVars") " : (" (p "VarEqualities") ")")
(simprinvinfo "sim " (p "(Mod11.Proc11 ~ Mod12.Proc12 : GlobVarEqualities1) ... (ModN1.ProcN1 ~ ModN2.ProcN2 : GlobalVarEqualitiesN)") " / " (p "InvariantGlobalVars") " : (" (p "VarEqualities") ")")

(felinfo "fel " (p "CodePosEndInit") " (" (p "CntrExpr") ") (" (p "StepUpperBndFun") ") (" (p "CntrBndExpr") ") (" (p "BadEvent")") [ " (p "Mod1.Proc1 : IncCntrPre1; ...; ModN.ProcN : IncCntrPreN") " ] " (p "Invariant"))

(rewriteequivinfo "rewrite equiv [{" (p "Memory") "} " (p "CodePos") " " (p "Direction (-)") " " (p "ProoftermEquiv") " (" (p "Arg1, ..., ArgN") " :@ " (p "ReturnVar") ")]")

(procchangeinfo "proc change " (p "CodePosChange") " : " (p "ExprNew"))

(procrewriteinfo "proc rewrite " (p "CodePosRewrite") " " (p "Proofterm"))
