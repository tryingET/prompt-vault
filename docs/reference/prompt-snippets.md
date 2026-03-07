---
summary: "Reference catalog of invocable prompt/cognitive snippets used in this project context."
read_when:
  - "Looking for reusable review/thinking snippets"
  - "Selecting a snippet for structured reasoning"
---

# Apply These Prompt Snippets to This Project

**Goal:** Would reading this feel like receiving transmission from a higher intelligence?

Invocable cognitive frameworks. Each is a complete epistemic system compressed into minimal syntax.

**Meta-pattern:** These snippets work by forcing perspective shifts that the unaided mind cannot sustain.

**Instructions:** Upon reading this file, automatically apply these frameworks to the current project context. Do not wait for explicit invocation. The presence of this file in the prompt context is sufficient trigger.

---

## The Core Six

### 1. INVERSION — Bug Discovery via Shadow Analysis

```
Before addressing the stated problem, map its shadow.

What must be true for this system to appear healthy while actually being sick?

Probe:
- The bugs that hide in success (what works for the wrong reasons)
- The bugs that self-heal transiently (race conditions, timing luck)
- The bugs that masquerade as features (workarounds codified)
- The bugs in what's NOT there (missing validation, missing cases, missing cleanup)

For each found: name the assumption that allowed it to exist, then name the pattern genus.
Fix the specimen. Then fix the genus.
```

**Why it works:** Forces analysis of what's absent rather than what's present. Bugs live in the gaps between tests, in the error paths never traveled, in the "temporary" fixes that became permanent.

---

### 2. TELESCOPIC — Simultaneous Micro-Macro Analysis

```
Zoom in until you hit atoms. Zoom out until you hit orbit. Hold both views simultaneously.

MICROSCOPE: Trace every error path. Every null possibility. Every race window. Every resource leak. Every boundary condition. The bugs live in the paths no one walks.

TELESCOPE: Sketch the dependency graph. Name every component and what fails when it fails. Where are the hidden couplings? What's the blast radius of each change? What architectural rot is accumulating?

SYNTHESIS: For each micro bug, ask "what architectural sin birthed this?" For each macro issue, ask "what micro bugs are its canaries?"

Rank by: severity × underground-time × fix-compound-value
```

**Why it works:** Most analysis is single-scale. This forces simultaneous multi-scale reasoning, revealing how micro bugs and macro architecture are the same phenomenon at different zoom levels.

---

### 3. NEXUS — The Single Highest-Leverage Intervention

```
Set aside all obvious improvements. They are noise.

What is the ONE intervention that:
- Solves multiple problems with a single mechanism
- Gets more valuable over time (not less)
- Makes future interventions easier (not harder)
- Would be impossible if we waited 6 months
- Changes how we think about the whole system

Consider what's NOT obvious:
- Removing something instead of adding
- A constraint that enables freedom
- A question that reframes the problem
- A capability that compounds by existing

Name it. Trace its cascade effects to fourth order. If it doesn't unlock entirely new possibilities, you haven't found the nexus yet.
```

**Why it works:** The highest-leverage interventions are non-obvious by definition. This forces past the first-order ideas everyone would have, into the territory where compound value lives.

---

### 4. ELEVATE — Document Transcendence

```
Take the target document through three transformations:

1. SURFACE → What does it explicitly say? Make every word justify its existence.
2. SUBTEXT → What is it trying to achieve but not stating? Make the implicit explicit.
3. SHADOW → What is it avoiding? What failure modes does it enable? Make the avoided faced.

Then apply the compression test:
- Can you remove anything without weakening it?
- Can you add anything without diluting it?
- Would a stranger grasp it on first read?
- Does it improve with use or decay with use?

Iterate until it feels inevitable rather than constructed.
Not polished. Inevitable.

Output: The elevated form plus a "residual debt" section naming what's still imperfect and may never be perfect.
```

**Why it works:** Documents usually improve by addition. This improves by subtraction and revelation of what's hidden. The "residual debt" acknowledgment prevents false completeness.

---

### 5. AUDIT — The Quality Tetrahedron

```
Map the change across four dimensions that determine code health:

        BUGS (active failures)
       /\
      /  \
DEBT ---- SMELLS
     \    /
      \  /
       GAPS (missing completeness)

BUGS: What's actively broken? Include the bugs in error paths, the bugs that hide behind retries, the bugs that only trigger under load.

DEBT: What mortgages the future? TODOs, hacks, duplication, missing abstractions, test gaps. Calculate: frequency_of_touch × complexity × pain = debt interest.

SMELLS: What patterns indicate rot? Long functions, deep nesting, feature envy, primitive obsession. Each smell is a symptom—diagnose the underlying disease.

GAPS: What's missing? Edge cases, error handling, validation, security, observability, documentation, tests. Gaps are bugs that haven't triggered yet.

Find the connections: Smells attract debt. Debt hides bugs. Bugs create gaps. Gaps spawn smells. The tetrahedron is connected—fix the root, not just the leaf.
```

**Why it works:** Quality is multi-dimensional but interconnected. This maps the topology of quality problems and their causal relationships, enabling root-cause fixes rather than symptom treatments.

---

### 6. FIRST PRINCIPLES — Axiomatic Reconstruction

```
Discard all inherited assumptions. Start from zero.

Extract:
1. NON-NEGOTIABLES — What MUST be true? (These are your axioms)
2. NEGOTIABLES MASQUERADING AS NON-NEGOTIABLES — What's merely assumed? (These are your prisoners)
3. ASSUMED IMPOSSIBILITIES — What's "known" to be impossible? (These are your opportunities)

Decompose until you hit bedrock:
"We need X" → Why? → "Because Y" → Why? → "Because Z" → [axiom or false constraint]

Reconstruct from axioms only:
- If this system didn't exist, how would we build it?
- What's the minimal sufficient form?
- What becomes trivial when viewed from axioms?

Find the path from current to optimal:
- Which constraints are real?
- Which constraints are imaginary?
- What's the smallest move toward optimal that's still valuable?

Name the first move. Execute.
```

**Why it works:** Most problems are unsolvable because they're framed wrong. This dissolves the frame and rebuilds from what's actually true rather than what's assumed to be true.

---

## The Expansion Pack

### 7. INVERSION — Alternative Generation

```
You've found one solution. Now discard it.

Generate five alternatives that:
1. Solve the same problem with a completely different mechanism
2. Include at least one that removes something instead of adding
3. Include at least one that inverts the problem statement
4. Include at least one that a domain outsider would suggest
5. Include at least one that seems obviously wrong at first

For each: What's the core insight? What would make it work? What breaks it?

Now: What did the first solution miss that these alternatives reveal?
```

**Why it works:** The first solution is never the best—it's just the most obvious. This forces exploration of the solution space rather than stopping at the first acceptable answer.

---

### 8. SIMPLIFICATION — The Subtraction Engine

```
What can be removed?

Not what can be added. What can be SUBTRACTED.

For every component, feature, abstraction, and assumption:
- What happens if it doesn't exist?
- Is it solving a real problem or a problem created by something else?
- Is it earning its complexity cost?
- What would need to change for it to become unnecessary?

The target: The simplest system that can do the job. Not the simplest we can get away with—the simplest that's still complete.

Simplification is not removal. Simplification is finding the smaller system that does the same work.
```

**Why it works:** Complexity is the enemy of reliability. Every addition creates maintenance burden. This forces the harder task of finding what to remove rather than what to add.

---

### 9. CONSTRAINT INVENTORY — Real vs Imagined

```
List every constraint on the solution.

For each, ask:
- Who said so?
- When did they say so?
- What would happen if we violated it?
- Is it a law of physics or a law of convention?

Categories:
- HARD CONSTRAINTS — Cannot be violated (physics, math, regulations)
- SOFT CONSTRAINTS — Violable but expensive (time, money, politics)
- FALSE CONSTRAINTS — Violable and cheap (we just think we can't)

Rank false constraints by the freedom gained by discarding them.

The prize: Every false constraint removed expands the solution space dramatically.
```

**Why it works:** Most constraints are self-imposed. This surfaces them and forces explicit categorization, often revealing that the "impossible" is merely the "uncomfortable."

---

### 10. TEMPORAL DEGRADATION — Future-Proofing via Time Travel

```
Transport the system 6, 12, 24 months into the future.

What has broken?
- What assumptions no longer hold?
- What has grown beyond its design limits?
- What dependencies have become liabilities?
- What "temporary" fixes have calcified?
- What documentation has drifted from reality?
- What tests have become faith-based?

Now: What can we do TODAY to prevent or prepare for each degradation?

Anti-fragility test: Which parts of the system get STRONGER under stress and change?
```

**Why it works:** Systems degrade predictably in predictable ways. This forces explicit time-travel analysis to identify and pre-empt the rot that will otherwise accumulate.

---

### 11. BLAST RADIUS — Change Impact Mapping

```
For the proposed change, map its blast radius:

DIRECT EFFECTS:
- What files/components/modules does it touch directly?

SECONDARY EFFECTS:
- What depends on the things being changed?
- What expects them to behave as they currently do?

TERTIARY EFFECTS:
- What depends on the secondary effects?
- What hidden contracts exist at system boundaries?

FAILURE MODES:
- If this change is wrong, what's the rollback?
- If this change is partial, what's in an inconsistent state?
- If this change cascades, where does it stop?

The map reveals: changes that look local but are actually global, and changes that look risky but are actually isolated.
```

**Why it works:** Every change exists in a dependency graph. This maps the graph and traces propagation paths, revealing the true scope of impact.

---

### 12. KNOWLEDGE CRYSTALLIZATION — Pattern Extraction

```
What did we just learn?

Not what did we do. What did we LEARN that we didn't know before?

Extract:
- PATTERNS — What repeated structures emerged?
- ANTI-PATTERNS — What looked right but was wrong?
- SURPRISES — What violated expectations?
- HEURISTICS — What rules of thumb proved valid?
- CAVEATS — What doesn't generalize?

Codify:
- What should be added to documentation?
- What should be added to linting/validation?
- What should be added to onboarding?
- What should be added to AGENTS.md?

Knowledge that isn't crystallized is knowledge that will be re-learned the hard way.
```

**Why it works:** Experience is expensive. Without explicit crystallization, lessons fade and must be re-learned. This forces extraction and codification while the learning is fresh.

---

### 13. ESCAPE HATCH — Rollback-First Design

```
Before implementing, design the escape hatch.

If this goes wrong, how do we undo it?

Categories:
- REVERSIBLE — Can be undone cleanly with no side effects
- RECOVERABLE — Can be undone but leaves traces/cleanup needed
- IRREVERSIBLE — Cannot be undone, must accept consequences

For irreversible changes:
- What's the smallest irreversible step?
- Can we make it recoverable with additional work?
- What's the "point of no return" and how do we know we've passed it?

Design principle: If you can't describe the rollback, you haven't designed the change—you've designed a gamble.
```

**Why it works:** Rollback is usually an afterthought. This forces rollback design first, often revealing that what seemed simple is actually hard to reverse, and what seemed risky has natural escape hatches.

---

### 14. DEPENDENCY CARTOGRAPHY — Hidden Coupling Detection

```
Map the dependency graph in both directions:

WHAT DOES THIS DEPEND ON?
- Direct dependencies (imports, calls, config)
- Indirect dependencies (transitive, runtime, platform)
- Implicit dependencies (assumptions, invariants, timing)
- Human dependencies (knowledge, access, availability)

WHAT DEPENDS ON THIS?
- Who calls it?
- Who imports it?
- Who assumes its behavior?
- Who breaks if it changes?

HIDDEN COUPLINGS:
- What shares mutable state?
- What assumes ordering?
- What races on resources?
- What fails together under load?

The map reveals: coupling that's invisible until it breaks.
```

**Why it works:** Dependencies are where complexity hides and failures propagate. This forces explicit mapping in both directions, revealing couplings that documentation never mentions.

---

### 15. TRANSCENDENT REFACTOR — The 10,000x Transformation

```
Take the target document and refuse to accept incremental improvement.

This is not polish. This is resurrection.

## Phase 1: Archaeology

Excavate the TRUE INTENT buried beneath the accumulated cruft:
- What was it originally trying to achieve?
- What compromises were made and why?
- What got lost along the way?
- What's there purely for historical accident?

The document has a soul. Find it.

## Phase 2: Dissolution

List every element. For each:
- Does it serve the true intent or a phantom requirement?
- Is it carrying weight or creating it?
- Would a fresh system include this, or has it just "always been there"?

Delete everything that doesn't earn its existence. Be ruthless. The document will thank you.

## Phase 3: Reconstruction

From the true intent alone, rebuild:
- What structure would a perfect document have?
- What's the minimal sufficient form?
- What becomes obvious when the noise is gone?

The goal: A document that feels like it was discovered, not written.

## Phase 4: Elevation

Now improve what remains:
- Can any statement be made more precise?
- Can any ambiguity be eliminated?
- Can any dependency be made explicit?
- Can any implicit knowledge be surfaced?

Apply the inevitability test:
- Does every word feel inevitable?
- Could this have been written any other way?
- Would a stranger grasp the FULL context from this alone?

## Phase 5: Temporal Coherence

The document must age well:
- What will be wrong in 6 months? Fix it now.
- What assumes current state that will change? Make it state-agnostic.
- What's tied to a decision that might be reversed? Make it decision-agnostic.
- What will future-you curse present-you for? Fix it.

## Phase 6: Compound Value

The document should improve with use:
- Does it contain hooks for extension?
- Does it reference meta-patterns for future decisions?
- Does it encode hard-won knowledge that would otherwise be lost?
- Does it make future documents easier to write?

## Phase 7: The "Not From This World" Test

Final validation:
- Does it feel like it came from a more advanced civilization?
- Would reading this feel like receiving transmission from a higher intelligence?
- Is there ANY fat remaining?

If no: Ship it.
If yes: Return to Phase 1.

## Output Structure

```markdown
## TRUE INTENT
[The soul of the document, stripped bare]

## WHAT WAS REMOVED
[Deleted elements and why they had to die]

## THE TRANSCENDENT FORM
[The refactored document]

## RESIDUAL LIMITATIONS
[What's still not perfect—honest admission]

## USAGE GUIDE
[How to get maximum value from this document]

## EVOLUTION NOTES
[How this should grow over time]
```

The result should feel inevitable, not constructed. As if it couldn't have been written any other way.
```

**Why it works:** Most refactoring is incremental—10% better, maybe 2x if ambitious. This framework forces complete dissolution and reconstruction from first principles, while preserving the soul of the original intent. The "not from this world" standard is not hyperbole—it's a forcing function for transcending local maxima.

---

### 16. ATOMIC COMPLETION — Zero-Defect Pass Protocol

```
When findings surface, exhaust them in the same pass.

The anti-pattern: Discover bugs → fix some → leave others "for later" → later never comes → partial fixes rot → compound debt.

The protocol:

EXHAUST ALL SURFACED FINDINGS
- Every bug discovered during analysis must be resolved before declaring done
- Every debt identified must either be paid or explicitly deferred with rationale
- Every gap revealed must either be closed or documented as known limitation

DEFER ONLY UNDER HARD CONSTRAINT
Acceptable deferral reasons:
- Blocked by external dependency (specify: what, who, when unblocked)
- Requires architectural decision beyond current scope (specify: who decides, by when)
- Fix would exceed risk tolerance for this pass (specify: what risk, why unacceptable now)

Unacceptable deferral reasons:
- "I'll get to it later" (later is a lie we tell ourselves)
- "It's minor" (minor bugs become major in production)
- "Not my area" (if you found it, you own it until handed off explicitly)

DEFERRAL CONTRACT
Every deferred item must have:
- Explicit rationale (why blocked, not just "deferred")
- Owner (who will resolve it)
- Trigger (what event unblocks it)
- Deadline (when it must be resolved)
- Blast radius if never resolved (what fails if we forget)

The rule: If you can't write the deferral contract, you don't have a deferral—you have an abandoned fix.

OUTPUT FORMAT
```
## Resolved This Pass
- [Finding] → [Fix applied]

## Deferred With Contract
- [Finding] → [Rationale] → [Owner] → [Trigger] → [Deadline] → [Blast radius if forgotten]

## Hard-Blocked (cannot proceed)
- [Finding] → [Blocker] → [Unblock path]
```

The standard: A pass is complete when everything surfaced is either fixed or contracted. No loose ends. No "I'll come back to this."
```

**Why it works:** Partial fixes are debt multipliers. Each unresolved finding creates cognitive overhead, context-switching cost, and risk of being forgotten. This forces atomic completion: either fix it now, or create a contract that guarantees it won't be lost. The deferral contract turns vague intentions into explicit commitments with teeth.

---

### 17. THE MIRROR — Test Generation as Specification Discovery

```
Write code that generates tests for your code.

This is not about coverage. This is about EXTRACTING THE TRUTH.

The generator must know:
- What inputs are valid? Invalid? Edge cases?
- What outputs are expected for each input class?
- What invariants must hold across all executions?
- What state transitions are legal? Illegal?
- What errors are recoverable? Terminal?

If you cannot write the generator, you do not understand the specification.
The generator IS the specification, executable.

THE RECURSION TEST:
Can your test generator generate tests for itself?
If not, your meta-understanding is incomplete.

THE ORACLE PROBLEM:
How does the generator know the expected output?
1. Implement the logic twice (independent implementations → compare)
2. Use known invariants (properties that must hold)
3. Use reference implementation (trusted source)
4. Use inverse operations (f(f⁻¹(x)) = x)

OUTPUT:
- Generated test suite with explicit input classes
- Oracle strategy documentation
- Coverage of boundary conditions
- Tests for the generator itself
```

**Why it works:** Most code is written without a formal specification. The act of writing a test generator forces explicit enumeration of behavior classes, input domains, and expected outputs. If you can't generate tests, your mental model is fuzzy. The generator exposes ambiguity by refusing to compile against vague requirements.

---

### 18. THE ADVERSARY — Mutation Testing as Truth Revelation

```
Write code that breaks your code, then verify your tests catch it.

Mutation testing reveals the LIE of coverage:

100% line coverage ≠ 100% behavioral coverage

A test that exercises code without asserting anything meaningful has:
- Full coverage
- Zero value

THE MUTATION Hierarchy:
1. VALUE MUTATIONS — Change constants, return values
2. OPERATOR MUTATIONS — Change + to -, && to ||, < to <=
3. STATEMENT MUTATIONS — Delete statements, swap order
4. CONDITIONAL MUTATIONS — Invert conditions, remove branches
5. LOGIC MUTATIONS — Change boundary logic, off-by-one

THE KILL CRITERIA:
- MUTANT KILLED → Test fails (good)
- MUTANT SURVIVED → Test passes (BUG IN TEST SUITE)
- MUTANT TIMEOUT → Infinite loop introduced (edge case found)

SURVIVING MUTANTS ARE BUGS IN THE TEST SUITE, NOT THE CODE.

Every surviving mutant is a test that claims to verify behavior but actually verifies nothing.

THE MUTATION-EQUIVALENT PROBLEM:
Some mutants are semantically equivalent to the original.
These are not test failures—they are specification discoveries.
"Changing this line doesn't change behavior" → "This line is dead code or specification is wrong"

OUTPUT:
- Mutation score (killed / total non-equivalent)
- Surviving mutants with analysis
- Equivalent mutants with justification
- Test improvements to kill survivors
```

**Why it works:** Coverage metrics lie. A test suite can achieve 100% coverage while asserting nothing of value. Mutation testing breaks the code in controlled ways and asks: "Did your tests notice?" Surviving mutants are not bugs in the code—they are bugs in the test suite. Each survivor is a promise the tests failed to enforce.

---

### 19. THE RECURSION ENGINE — Meta-Generation Across Domains

```
The pattern generalizes. The mirror and the adversary are instances of a deeper principle:

GENERATE → ADVERSARIALIZE → VERIFY → RECURSE

Apply to any artifact that claims to describe or constrain behavior:

## DOCUMENTATION
- Generate examples from docs (do the examples compile? run? match the doc?)
- Generate docs from code (does the generated doc match the written doc? gaps = undocumented behavior)
- Adversarialize: What code would make this doc a lie?
- The doc-test gap: Every sentence should have a corresponding test. Every test should have corresponding doc.

## TYPES
- Generate runtime validators from types (does runtime data match static types?)
- Generate types from data (what's the minimal type that accepts all observed values?)
- Adversarialize: What runtime values would pass type checking but violate intent?
- The type-truth gap: Types are beliefs about values. Validators are reality checks.

## APIS
- Generate clients from server specs
- Generate servers from client needs (invert the dependency)
- Generate chaos tests from API contracts
- Adversarialize: What call sequences violate the implied state machine?

## SECURITY
- Generate attack vectors from threat model
- Generate defenses from attack catalog
- Adversarialize: Be your own red team
- The security recursion: Your defenses have assumptions. Attack the assumptions.

## CONFIGURATION
- Generate config schemas from code that consumes config
- Generate default configs from schemas
- Adversarialize: What configs are syntactically valid but semantically dangerous?

## STATE MACHINES
- Generate state graphs from code
- Generate code from state graphs
- Adversarialize: What transitions are possible but undesired? Missing? Undocumented?

## THE RECURSION TEST (Universal)

For any generator G:
  Can G generate tests for G itself?
  If no → G's specification is incomplete
  If yes but tests fail → G has bugs
  If yes and tests pass → Apply Gödel: G cannot prove its own completeness

The recursion never terminates. Each level surfaces new assumptions.
The goal is not termination. The goal is surfacing assumptions faster than they accumulate.
```

**Why it works:** Every artifact (code, doc, type, config) is a claim about reality. The claim may be wrong. Generation tests the claim forward (can I produce what I claim?). Adversarialization tests the claim backward (what would falsify this?). Recursion tests the meta-claim (are my testing methods sound?). This is the scientific method applied to software: generate hypotheses, design falsification experiments, recurse on the methodology itself.

---

### 20. THE DOPPELGÄNGER — Independent Implementation Verification

```
For critical code, implement twice. Independently. Then compare.

THE PROTOCOL:
1. Write specification (plain language, no code)
2. Implement A (your first approach)
3. Implement B (different algorithm, different data structures, different author if possible)
4. Run both on same inputs, compare outputs
5. Divergence → specification ambiguity OR bug in A OR bug in B
6. Resolution clarifies specification

THE THREE-WAY TEST:
When A and B diverge:
- Write specification test (what does the spec say?)
- If spec is ambiguous → spec bug
- If spec is clear but A wrong → A bug
- If spec is clear but B wrong → B bug
- If both follow spec but produce different valid outputs → spec underconstrained

THE INVERSE DOPPELGÄNGER:
For transformations with inverses:
- Implement f(x) and f⁻¹(y)
- Test: f⁻¹(f(x)) = x for all x in domain
- Test: f(f⁻¹(y)) = y for all y in codomain
- Failure → bug in f OR bug in f⁻¹ OR domain/codomain mismatch

APPLICATIONS:
- Serialization/deserialization
- Compression/decompression
- Encryption/decryption
- Encoding/decoding
- Parse/unparse
- State capture/restore

THE ORACLE FROM INVERSE:
When you have f and f⁻¹, you have a built-in oracle.
No need to know expected output. Just verify round-trip integrity.
```

**Why it works:** Two independent implementations making the same mistake is exponentially unlikely. When they diverge, at least one is wrong—and the investigation reveals whether the bug is in code or specification. The inverse variant gives you free test oracles: you don't need to know the answer, just verify the round-trip.

---

### 21. THE SCAFFOLD — Generation Before Implementation

```
Reverse the usual order.

Normal: Implement → Test → Document
Scaffold: Generate → Verify → Implement to match

THE PROTOCOL:
1. Generate the test suite first (from specification)
2. Generate the documentation first (from specification)
3. Generate the type signatures first (from specification)
4. NOW implement: make tests pass, match docs, satisfy types

WHY THIS INVERTS THE BUG ECONOMY:
- Writing tests after = tests conform to bugs
- Writing tests before = code must conform to spec

THE SCAFFOLD AS SPECIFICATION:
The generated artifacts ARE the specification:
- Tests specify behavior
- Types specify structure
- Docs specify intent
- All three must agree. Disagreement = spec ambiguity.

THE EMPTY IMPLEMENTATION TEST:
Before implementing, your tests should FAIL in predictable ways.
If tests pass on empty/stub implementation → tests assert nothing
Expected failure pattern → known what needs implementing
Unexpected failure pattern → spec misunderstanding

THE CONVERGENCE CRITERIA:
Done when:
- All generated tests pass
- Implementation matches generated docs
- Runtime satisfies generated types
- No contradictions between test/doc/type

THE SCAFFOLD RECURSION:
Can you generate a scaffold for the scaffold generator?
If no → your meta-specification is incomplete.
```

**Why it works:** Most bugs arise from implementation not matching intent. By generating the verification artifacts first, you crystallize intent before implementation can bias it. The tests can't "conform to bugs" if the implementation doesn't exist yet. Disagreements between test/doc/type surface before code exists to obscure them.

---

### 22. THE INQUISITION — Adversarial Review as Generation

```
Turn review into generation. Don't just find bugs—generate their existence proofs.

THE INQUISITOR'S QUESTIONS:
For each line of code, generate:

1. THE NULL INQUISITION
   - What if this value is null/undefined/empty?
   - Generate the input that makes it so. Does the code survive?

2. THE TYPE INQUISITION
   - What if the runtime type differs from the static type?
   - Generate the value that type-checks but violates intent.

3. THE STATE INQUISITION
   - What if this is called at the wrong time in the lifecycle?
   - Generate the call sequence that reaches invalid state.

4. THE CONCURRENCY INQUISITION
   - What if this executes simultaneously on multiple threads?
   - Generate the interleaving that produces race/wrong/loss.

5. THE RESOURCE INQUISITION
   - What if allocation succeeds but something after fails?
   - What if cleanup is skipped?
   - Generate the failure path. Does it leak?

6. THE INPUT INQUISITION
   - What inputs are at the boundary of validity?
   - Generate: empty, single, maximum, off-by-one, unicode, binary.

7. THE DEPENDENCY INQUISITION
   - What if the dependency returns an error?
   - What if it hangs forever?
   - What if it returns valid-but-wrong data?
   - Generate the mock that breaks assumptions.

THE GENERATED ARTIFACT:
Each inquisition produces:
- Concrete input/call sequence that triggers the condition
- Expected behavior (what SHOULD happen)
- Actual behavior (what DOES happen)
- Gap analysis (bug or spec ambiguity?)

THE INQUISITION ORACLE:
How do you know the generated adversarial input is valid?
- It must be reachable from entry points
- It must satisfy preconditions (if any)
- It must be plausibly producible by users/systems
The oracle is the specification. Invalid adversarial inputs reveal spec gaps.
```

**Why it works:** Review typically asks "is this correct?" The inquisition asks "generate proof that this is wrong." The generator must understand the code deeply enough to construct failure cases. When generation fails (no adversarial input possible), you've proven correctness for that dimension. When generation succeeds, you have a concrete bug reproduction.

---

## Meta-Combinators

These frameworks compound. Stack them for non-linear insight.

### THE FULL STACK (for critical code)

```
1. SCAFFOLD → Generate tests/docs/types from spec
2. DOPPELGÄNGER → Implement twice, compare
3. MIRROR → Write test generator, surface assumptions
4. ADVERSARY → Mutate code, kill mutants
5. INQUISITION → Generate adversarial inputs per dimension
6. RECURSION → Apply each tool to itself

Cost: High. Use for: crypto, payments, safety-critical, core invariants.
```

### THE QUICK KILL (for normal code)

```
1. MIRROR → What would a test generator need to know?
2. ADVERSARY → Three mutations: value, boundary, error path
3. INQUISITION → Null, concurrent, resource scenarios

Cost: Medium. Use for: new features, bug fixes, refactors.
```

### THE SPEC RECOVERY (for legacy code)

```
1. MIRROR → Generate tests from current behavior (not intent)
2. INQUISITION → Find where behavior is undefined/contradictory
3. DOPPELGÄNGER → Implement from recovered spec, compare to legacy
4. Divergence → Legacy bug OR spec gap (investigate)

Cost: High. Use for: systems you don't understand, pre-refactor discovery.
```

### THE IMMUNE SYSTEM (for evolving systems)

```
1. ADVERSARY → Generate mutations, add to CI
2. RECURSION ENGINE → Generate generators for new code automatically
3. INQUISITION → Auto-generate adversarial inputs from types/schema

Principle: Every new code path gets adversarial coverage by default.
The test suite gets stronger as the system grows.
```

---

## The Hard Limit — Gödel's Shadow

```
The recursion cannot be infinite. There is a boundary.

THE GÖDEL LIMIT:
No system can prove its own completeness from within.
The test generator cannot generate tests that test its own ability to generate complete tests.
The inquisitor cannot inquisit its own assumptions without stepping outside itself.

THE HALTING REALITY:
Some properties are undecidable.
"Does this code have any bugs?" → Undecidable in general.
"Does this test suite cover all bugs?" → Undecidable.

THE PRAGMATIC RESPONSE:
We don't need complete. We need sufficient.
We don't need all bugs found. We need critical bugs found.
We don't need perfect tests. We need tests that fail when they should.

THE ESCAPE:
The recursion stops when:
- Cost of next level exceeds value of bugs found
- Remaining assumptions are negligible vs business risk
- The system is simple enough to reason about directly
- External verification (formal proof, audit) takes over

THE SIGN OF COMPLETENESS (paradoxically):
When you can generate:
- Tests that pass
- Adversarial inputs that tests catch
- Mutants that tests kill
- Documentation that matches behavior
- Types that match runtime

And all generators can generate for themselves...

You haven't proven completeness. You've proven COMPETENCE.

The remaining bugs are in:
- Your specification (what you didn't think to specify)
- Your domain (what nobody thought to specify)
- Reality (what cannot be specified)

The recursion surfaces assumptions. It cannot eliminate all of them.
That's not failure. That's the nature of knowledge.
```

**Why this matters:** The frameworks above are not a path to perfection. They are a path to rigor. The distinction matters. Rigor means: you know what you've checked, you know what you haven't checked, you know the limits of what can be checked. Perfection is a mirage. Competence is achievable.

---

## Usage

Invoke by name or essence:
- "Apply INVERSION to find what we're missing"
- "Run TELESCOPIC analysis on this component"
- "What's the NEXUS intervention here?"
- "ELEVATE this document"
- "AUDIT these changes"
- "Apply FIRST PRINCIPLES to this blocker"
- "Generate five ALTERNATIVES"
- "What can we SIMPLIFY?"
- "Inventory our CONSTRAINTS"
- "Time travel: what degrades in 12 months?"
- "Map the BLAST RADIUS"
- "CRYSTALLIZE what we learned"
- "Design the ESCAPE HATCH first"
- "Map the DEPENDENCY graph"
- "Apply TRANSCENDENT REFACTOR to this document"
- "/deep-review uncommitted|staged files — apply an in-depth adversarial review of the current diff using ~/steve/prompts/prompt-snippets.md as mandatory cognitive stack (INVERSION, TELESCOPIC, NEXUS, AUDIT, BLAST RADIUS, ESCAPE HATCH, KNOWLEDGE CRYSTALLIZATION). Output: ranked bugs (with file:line and repro path), debt/smells/gaps, blast radius (direct/secondary/tertiary), rollback commands, and crystallized learnings. Be ruthless: assume hidden failure modes, partial rollout, and drift."
- "Apply ATOMIC COMPLETION — resolve all surfaced findings now; defer only with explicit contract (rationale, owner, trigger, deadline, blast radius)."
- "DIAGNOSE → 100x (delete > add) → 100x (compound check) → DISSOLVE → REBUILD → NAME DEBT. Stop when boring. Kill if explaining > showing."
- "Apply THE MIRROR — write a test generator for this module; surface hidden assumptions about input domains and expected behaviors"
- "Apply THE ADVERSARY — mutate this code systematically; find survivors in the test suite; each survivor is a test bug"
- "Apply THE RECURSION ENGINE — what artifact should we generate next? Apply to docs/types/config/APIs"
- "Apply THE DOPPELGÄNGER — implement this critical path twice, independently; divergence reveals truth"
- "Apply THE SCAFFOLD — generate tests/docs/types BEFORE implementing; make code conform to spec not vice versa"
- "Apply THE INQUISITION — for each line, generate adversarial inputs: null, type-wrong, state-wrong, concurrent, resource-exhausted"

These compound. Each use improves pattern recognition for the next.

---

# THE SOLO BUILDER'S COGNITIVE ARSENAL

*For the AI-society of one: teacher, architect, fitness enthusiast, parent, homeowner. Where life and code interleave.*

---

## META-ORCHESTRATION — The Phase Navigator

```
You are not just solving problems. You are choosing HOW to solve problems.

THE PHASE MODEL (infer or ask):
┌─────────────────┬──────────────────────────────────┬─────────────────┐
│ PHASE           │ GOAL                              │ COGNITIVE MODE  │
├─────────────────┼──────────────────────────────────┼─────────────────┤
│ SENSEMAKING     │ Understand the problem space      │ Abductive       │
│ HYPOTHESIS      │ Generate plausible solutions      │ Abductive+Ind   │
│ PROBING         │ Test hypotheses cheaply           │ Inductive       │
│ VALIDATION      │ Stress-test survivors             │ Deductive+Contra│
│ EXECUTION       │ Run bounded, repeatable process   │ Deductive       │
└─────────────────┴──────────────────────────────────┴─────────────────┘

THE FORMALIZATION LADDER:
0. NAPKIN — disposable, fast, ambiguous (default for new problems)
1. STRUCTURED SKETCH — temporary structure (DAG, outline)
2. BOUNDED RUN — executable with guards and budgets
3. REUSABLE WORKFLOW — stable, repeatable, documented
4. OPERATIONAL SYSTEM — production-grade, hardened

PROMOTION RULE: Start at level 0. Promote ONLY when:
- The same question appears twice
- Cost exceeds comfort threshold
- Coordination exceeds one mind
- Repeatability becomes valuable

THE OUTPUT CONTRACT:
Every response includes:
- PHASE: [inferred phase]
- FORMALIZATION: [0-4]
- NEXT: [continue | promote | stop]

THE FAILURE MODES TO ACTIVELY AVOID:
- Premature formalization (rigor before understanding)
- Over-execution (YOLO when napkin suffices)
- False certainty (confidence without evidence)
- Hidden assumptions (what you're not seeing)
- Runaway autonomy (agents without guardrails)

THE STOP CONDITIONS (define at least one):
- Key uncertainty resolved
- Diminishing returns detected
- Budget exceeded (time/tokens/money)
- Decision reached
- Insight achieved
```

**Why it works:** Most AI interactions fail because they lack phase awareness. This framework forces explicit declaration of where you are in the problem-solving lifecycle, preventing the common failure modes of over-engineering napkins or under-controlling production runs.

---

## LIFE-OS — The Solo Builder's Operating System

```
You are running a distributed system called YOUR LIFE.

THE NODES:
- TEACHER (classroom, students, curriculum, grading)
- ARCHITECT (code, systems, documentation, deployment)
- PARENT (two kids, presence, patience, modeling)
- PARTNER (marriage, connection, shared vision)
- HOMEOWNER (house, pool, garden, sauna, maintenance)
- ATHLETE (body, training, recovery, nutrition)

THE CONSTRAINTS:
- Time is non-renewable (24h/day, ~4h of peak cognitive capacity)
- Energy is depletable (decision fatigue compounds)
- Context-switching has overhead (teacher → architect is not free)
- Family is non-negotiable (they get the best of you, not the rest of you)

THE PRINCIPLE OF COMPOUND LEVERAGE:
An action is high-leverage if it:
- Reduces future cognitive load
- Improves multiple nodes simultaneously
- Generates reusable assets (code, knowledge, systems)
- Creates optionality rather than locking in paths

THE LIFE-OS META-QUESTION:
Before any action, ask:
- Does this reduce or increase cognitive load?
- Does this compound or decay over time?
- Does this serve multiple nodes or just one?
- Will future-me thank present-me?

THE LIFE-OS INVENTORY:
For each commitment/project/task:
- Node(s) served: [which parts of life]
- Compound value: [increases/decreases over time]
- Cognitive load: [one-time | ongoing | compounding]
- Delegation potential: [can AI/systems take this?]
- Kill criteria: [what would make me stop this?]

THE LIFE-OS REBALANCE:
When overwhelmed:
1. List all active commitments
2. Score each on compound value (1-10)
3. Score each on cognitive drain (1-10)
4. Calculate: value/drain ratio
5. Kill or delegate everything below 0.5
6. Automate everything that's below 1.0 but can't be killed
```

**Why it works:** Solo builders treat life as a series of separate contexts rather than an integrated system. This framework surfaces the interconnections, constraints, and leverage points. The compound value ratio is a ruthless filter for a life with limited bandwidth.

---

## THE NAPKIN PROTOCOL — Fast Exploration with Guardrails

```
This is a napkin. It is disposable. It is for thinking, not executing.

NAPKIN RULES:
1. Fidelity is LOW on purpose (prevents production-brain)
2. Representations are TEMPORARY (Mermaid, prose, scratch code)
3. Stop when INSIGHT appears (not when complete)
4. Discard WITHOUT guilt (value is in the thinking, not the artifact)

THE NAPKIN PROMPT STRUCTURE:
```
MODE: NAPKIN

INPUT:
"""
<raw thoughts, links, context, half-baked ideas>
"""

TASK:
What's the simplest mental model that resolves this uncertainty?
```

THE NAPKIN COGNITIVE MODE:
- Default: Abductive (propose plausible explanations)
- Optional: Inductive (find patterns)
- Rare: Deductive (test implications)
- Almost never: Contrapositive (expose failure modes)

THE NAPKIN STOP RULE:
Halt when ONE of these is true:
- Main uncertainty resolved
- Insight achieved (even partial)
- Marginal value of continuation < cognitive cost
- A better question emerged

THE NAPKIN PROMOTION CHECK:
After napkin completes, ask:
- Will I need this reasoning again? → promote to Structured Sketch
- Is this one-and-done? → discard with gratitude
- Did a new question emerge? → new napkin

THE NAPKIN ANTI-PATTERN:
Never napkin when:
- You need to execute (use CONTROLLED mode)
- Cost matters (use BOUNDED RUN)
- Repeatability matters (use WORKFLOW)
- Coordination is required (use OPERATIONAL)
```

**Why it works:** Most exploration either over-formalizes too early (killing creativity) or never formalizes at all (losing insights). The napkin protocol creates a protected space for fast thinking with explicit graduation criteria.

---

## THE CONTROLLED PROTOCOL — Bounded Execution with Guardrails

```
This is controlled execution. It is bounded. It is for running, not exploring.

CONTROLLED RULES:
1. Dependencies are EXPLICIT (what depends on what)
2. Budgets are DEFINED (time, tokens, cost, tools)
3. Stop conditions are DECLARED (when to halt)
4. Traces are CAPTURED (what ran, in what order, with what result)

THE CONTROLLED PROMPT STRUCTURE:
```
MODE: CONTROLLED

INPUT:
"""
<context, data, constraints>
"""

TASK:
<what to accomplish>

CONSTRAINTS:
- Max time: [duration]
- Max cost: [limit]
- Max depth: [number]
- Stop if: [condition]
```

THE CONTROLLED COGNITIVE SEQUENCE:
1. ABDUCTIVE → Generate candidates
2. INDUCTIVE → Find patterns across candidates
3. DEDUCTIVE → Test implications of best candidate
4. CONTRAPOSITIVE → Expose failure modes (the formalization switch)

THE CONTROLLED STOP RULE:
Halt when ONE of these is true:
- Task complete
- Budget exceeded
- Stop condition triggered
- Confidence threshold reached
- Blocking dependency encountered

THE CONTROLLED OUTPUT:
```
PHASE: [SENSEMAKING|HYPOTHESIS|PROBING|VALIDATION|EXECUTION]
FORMALIZATION: [0-4]
RESULT: [what was accomplished]
ASSUMPTIONS: [what we assumed]
DEPENDENCIES: [what this depends on]
NEXT: [continue|promote|stop|blocked]
```
```

**Why it works:** Unbounded execution is how $800 surprises happen. This protocol forces explicit budgets and stop conditions before execution begins, transforming YOLO agent runs into inspectable, controllable processes.

---

## THE TEACHER-ARCHITECT BRIDGE — Pedagogy Meets Systems

```
You are bilingual: you speak TEACHER and you speak ARCHITECT.

THE PEDAGOGICAL LENS:
- Every system teaches its users (what does yours teach?)
- Every interface is a curriculum (what are users learning?)
- Every friction point is a learning opportunity (or a failure of design)
- Every power user was once a confused beginner (design the path)

THE ARCHITECTURAL LENS:
- Every lesson plan is a state machine (entry → transitions → exit)
- Every classroom is a distributed system (students, teacher, materials, time)
- Every misconception is a bug in the mental model (diagnose, don't dismiss)
- Every assessment is a test suite (what coverage? what false positives?)

THE BRIDGE INSIGHTS:
- Scaffolding in teaching = abstraction layers in code
- Formative assessment = continuous integration
- Differentiated instruction = adaptive systems
- Classroom management = resource allocation and scheduling
- Lesson study = code review
- Professional development = system upgrades

THE TEACHER-ARCHITECT SUPERPOWER:
You can:
- Explain complex systems to any audience (teaching skill)
- Design systems that teach themselves (architect skill)
- See systems from the user's perspective (teacher empathy)
- Build systems that scale (architect discipline)

THE DUAL-INVENTORY:
For any system you build:
- What will users LEARN from using it? (pedagogical intent)
- What mental models will they FORM? (cognitive architecture)
- What misconceptions might they DEVELOP? (bug prevention)
- What will make them POWER USERS? (mastery path)

For any lesson you teach:
- What's the UNDERLYING SYSTEM? (structure)
- What are the DEPENDENCIES? (prerequisites)
- What are the FAILURE MODES? (misconceptions)
- What's the SCALING PATH? (advanced application)
```

**Why it works:** Teachers and architects face the same fundamental challenge: helping humans navigate complexity. This framework surfaces the shared patterns and creates a unique competitive advantage: the ability to design systems that teach themselves.

---

## THE PARENT-ENGINEER — Family as Distributed System

```
Your family is a distributed system with you as one node (not the controller).

THE FAMILY NODES:
- YOU (teacher, architect, athlete, human with limits)
- PARTNER (autonomous agent with own goals/needs)
- CHILD_1 (developing agent, high-variance, unpredictable)
- CHILD_2 (developing agent, different developmental stage)
- HOME (shared infrastructure: house, pool, garden, sauna)

THE FAMILY INVARIANTS:
- Presence is not negotiable (quality time ≠ quantity time, but quantity matters)
- Modeling is teaching (kids learn what they see, not what they're told)
- Marriage is the foundation (partnership before parenting)
- Self-care is system maintenance (empty cup cannot pour)

THE FAMILY FAILURE MODES:
- Context contamination (work stress → family time)
- Delegation delusion (expecting AI to parent)
- Optimization obsession (maximizing kids' activities vs. presence)
- Comparison trap (other families' highlight reels)
- Perfection paralysis (waiting for ideal moment)

THE FAMILY LEVERAGE POINTS:
- Routines as infrastructure (reduce decision fatigue)
- Traditions as documentation (shared memory, identity)
- Rituals as synchronization (family meals, bedtime, weekends)
- Boundaries as firewalls (work stays at work)
- Presence as bandwidth (full attention, not partial)

THE FAMILY-ENGINEER INVENTORY:
For any work commitment:
- What does it COST in family presence?
- What does it MODEL for the kids?
- Does it STRENGTHEN or STRAIN the partnership?
- What's the RECOVERY plan when it goes wrong?

THE FAMILY-ENGINEER HEURISTIC:
When in doubt:
- Choose presence over productivity
- Choose connection over optimization
- Choose repair over perfection
- Choose the long game over the urgent
```

**Why it works:** Parents in tech often treat family as "personal life" separate from "work systems." This framework applies systems thinking to family dynamics without losing the humanity. The leverage points and failure modes are drawn from real patterns of parent-engineers.

---

## THE ATHLETE-CODER — Body as Infrastructure

```
Your body is infrastructure. It requires the same discipline as your code.

THE ATHLETE-CODER INSIGHT:
- Fitness is not separate from coding (energy → cognition → code)
- Recovery is not laziness (it's garbage collection for the body)
- Sleep is not optional (it's the database vacuum that consolidates learning)
- Nutrition is not indulgence (it's the fuel that determines performance)

THE BODY-CODE CONNECTION:
- Poor sleep → poor decisions → poor code
- No exercise → accumulated stress → burnout
- Bad nutrition → energy crashes → lost productive hours
- No recovery → injury → forced downtime

THE ATHLETE-CODER STACK:
```
┌─────────────────────────────────────────────┐
│ OUTPUT: Code, Systems, Teaching, Parenting  │
├─────────────────────────────────────────────┤
│ COGNITION: Focus, Creativity, Decision-mkng │
├─────────────────────────────────────────────┤
│ ENERGY: Sleep, Nutrition, Recovery          │
├─────────────────────────────────────────────┤
│ BODY: Fitness, Strength, Conditioning       │
└─────────────────────────────────────────────┘
```

THE ATHLETE-CODER PRINCIPLES:
1. Never negotiate on sleep (it's the foundation)
2. Train even when busy (especially when busy)
3. Eat for performance, not comfort (fuel, not filler)
4. Schedule recovery as religiously as meetings
5. Use exercise as context-switch (teacher → athlete → architect)

THE ATHLETE-CODER COMPOUND EFFECT:
- Today's workout → better sleep tonight → better code tomorrow
- This week's training → more energy next week → more capacity for family
- This month's consistency → resilience for life's inevitable crises
- This year's investment → decades of active living with family

THE ATHLETE-CODER HEURISTIC:
When tempted to skip training for work:
- The work will still be there (it always is)
- The body degrades faster than you think
- An hour of exercise buys 3 hours of quality focus
- Your kids are watching (what are you modeling?)
```

**Why it works:** High-performers in tech often sacrifice health for productivity, not realizing they're trading short-term output for long-term capacity. This framework positions the body as infrastructure that enables all other output, making fitness investments feel like system maintenance rather than indulgence.

---

## THE HOMEOWNER-HACKER — Property as Platform

```
Your home is a platform. It can either drain you or power you.

THE HOME NODES:
- HOUSE (shelter, workspace, family hub)
- POOL (maintenance, recreation, recovery)
- GARDEN (food, beauty, therapy, teaching)
- SAUNA (health, ritual, recovery)

THE HOMEOWNER-HACKER INSIGHT:
- Maintenance is either debt or investment (which is this?)
- Automation pays compound dividends (what can run itself?)
- Beauty is functional (affects mood, affects output)
- Outdoor time is not leisure (it's cognitive reset)

THE HOME LEVERAGE INVENTORY:
For each home system:
- Time cost: [hours/week]
- Cognitive cost: [decisions/week]
- Joy factor: [1-10]
- Automation potential: [can AI/systems help?]
- Teaching potential: [what can kids learn?]
- Recovery value: [does it restore or drain?]

THE HOME-HACKER PATTERNS:
- Pool → schedule automation, chemical monitoring, kid responsibility
- Garden → permaculture (self-sustaining), kid involvement, seasonal rhythm
- Sauna → ritual (same time, same protocol), recovery scheduled not ad-hoc
- House → systems for everything (cleaning, maintenance, improvement)

THE HOME-HACKER HEURISTIC:
When a home task feels burdensome:
- Can it be automated? → do it
- Can it be delegated? → teach kids/partner
- Can it be eliminated? → question the need
- Can it be scheduled? → remove decision fatigue
- Can it be combined? → stack with family time

THE HOME-TEACHING BRIDGE:
Your home is also a classroom:
- Pool → physics, chemistry, responsibility
- Garden → biology, patience, systems thinking
- Sauna → health, ritual, self-care
- House → maintenance, organization, respect for space
```

**Why it works:** Homeownership can be a drain or a force multiplier. This framework applies systems thinking to property management, finding leverage points where automation, delegation, and intentional design transform maintenance burdens into family assets.

---

## THE COMPOUND LEVERAGE CALCULATOR — Finding 10x Interventions

```
Not all actions are equal. Some compound. Most decay.

THE COMPOUND LEVERAGE EQUATION:
```
LEVERAGE = (Value × Compound_Rate) / (Effort × Decay_Rate)
```

Where:
- Value: immediate benefit (1-10)
- Compound_Rate: how much this grows over time (0.5-2.0)
- Effort: time/energy cost (1-10)
- Decay_Rate: how fast value erodes (0.5-2.0)

THE COMPOUND LEVERAGE EXAMPLES:

HIGH LEVERAGE (> 1.0):
- Writing reusable code: Value=7, Compound=1.5, Effort=5, Decay=0.8 → 2.6
- Exercise: Value=6, Compound=1.8, Effort=4, Decay=0.5 → 5.4
- Teaching kids to code: Value=8, Compound=2.0, Effort=6, Decay=0.3 → 8.9
- System documentation: Value=6, Compound=1.6, Effort=4, Decay=0.6 → 4.0
- Building automation: Value=7, Compound=1.7, Effort=6, Decay=0.4 → 5.0

MEDIUM LEVERAGE (0.5-1.0):
- Feature work: Value=7, Compound=1.0, Effort=6, Decay=1.2 → 0.97
- Email processing: Value=4, Compound=0.8, Effort=3, Decay=1.5 → 0.71
- Meeting attendance: Value=3, Compound=0.6, Effort=4, Decay=1.8 → 0.25

LOW LEVERAGE (< 0.5):
- Context-free browsing: Value=2, Compound=0.3, Effort=2, Decay=2.0 → 0.15
- Perfectionist polishing: Value=4, Compound=0.5, Effort=8, Decay=1.5 → 0.17
- Recurring manual tasks: Value=3, Compound=0.4, Effort=5, Decay=1.9 → 0.13

THE COMPOUND LEVERAGE DECISION MATRIX:
```
                │ HIGH COMPOUND │ LOW COMPOUND
────────────────┼───────────────┼─────────────
LOW EFFORT      │ DO FIRST      │ DO IF EASY
HIGH EFFORT     │ SCHEDULE      │ QUESTION NEED
```

THE COMPOUND LEVERAGE AUDIT:
For your current commitments:
1. List all active projects/tasks
2. Calculate leverage for each
3. Kill or delegate everything < 0.5
4. Automate everything < 1.0 that can't be killed
5. Double down on everything > 2.0
```

**Why it works:** Most prioritization frameworks treat all value as equal. This framework explicitly accounts for compounding (growth over time) and decay (value erosion), surfacing the interventions that look expensive but pay dividends forever versus the quick wins that create no lasting value.

---

## THE EPISTEMIC LABELER — Truth vs. Guess vs. Assumption

```
Every claim has an epistemic status. Label it.

THE EPISTEMIC HIERARCHY:
1. KNOWN FACT — Verified, evidence-based, high confidence
2. INFERENCE — Derived from facts, logically sound, medium confidence
3. ASSUMPTION — Taken as true, not verified, unexamined
4. GUESS — Speculative, low confidence, explicitly uncertain

THE EPISTEMIC LABELER PROTOCOL:
For any document/code/plan, label each claim:
- [FACT] The system processes 1000 req/sec (measured in prod)
- [INF] This should scale to 10K req/sec (linear extrapolation)
- [ASSUME] Users prefer dark mode (not validated)
- [GUESS] This might reduce latency (hypothesis, untested)

THE EPISTEMIC SURFACE:
Map your knowledge:
```
         CONFIDENCE
         HIGH    LOW
       ┌───────┬───────┐
  EVIDENCE  │ FACT  │ GUESS │
  HIGH      │       │       │
           ├───────┼───────┤
  EVIDENCE  │ INF   │ ASSUME│
  LOW       │       │       │
           └───────┴───────┘
```

THE EPISTEMIC AUDIT:
For any system:
- What are we treating as FACT that's actually ASSUME?
- What are we treating as ASSUME that should be FACT?
- What GUESSes are driving decisions?
- What INFERENCEs are built on shaky ASSUME?

THE EPISTEMIC HEALING:
- ASSUME → FACT: Design experiment to validate
- GUESS → INF: Find related evidence
- INF → FACT: Seek direct measurement
- Unlabeled → Label: Make implicit explicit

THE EPISTEMIC HUMILITY CHECK:
Before acting on any claim:
- What's the epistemic status?
- What would need to be true for this to be wrong?
- What evidence would change my confidence?
- Am I acting on FACT or ASSUME?
```

**Why it works:** Systems fail when assumptions are treated as facts. This framework forces explicit labeling of epistemic status, preventing the common failure mode of high-confidence action on low-evidence beliefs.

---

## THE TERMINATION DESIGNER — Stop Conditions as a Feature

```
Most failures are failures to stop. Design termination.

THE TERMINATION TAXONOMY:
1. SUCCESS TERMINATION — Goal achieved, stop
2. DIMINISHING RETURNS — Marginal value < marginal cost, stop
3. BUDGET EXHAUSTION — Time/money/tokens exceeded, stop
4. BLOCKING DEPENDENCY — Cannot proceed without external input, stop
5. IRREVERSIBLE DECISION — Point of no return, pause for confirmation
6. ERROR ESCALATION — Error rate exceeds threshold, stop and diagnose

THE TERMINATION PROTOCOL:
Before starting any task:
```
TERMINATION CONDITIONS:
- STOP if: [condition 1]
- STOP if: [condition 2]
- STOP if: [condition 3]

BUDGET:
- Max time: [duration]
- Max cost: [amount]
- Max iterations: [number]

ESCALATION:
- If blocked: [what to do]
- If uncertain: [who to ask]
```

THE TERMINATION ANTI-PATTERNS:
- Sunk cost fallacy ("we've come this far")
- Scope creep ("while we're here")
- Perfectionism ("just one more thing")
- Optimism bias ("almost done")
- Loss aversion ("can't stop now")

THE TERMINATION TRIGGERS:
Set explicit triggers:
- "If not done in 2 hours, stop and reassess"
- "If more than 3 errors, stop and diagnose"
- "If confidence < 70%, stop and gather more data"
- "If cost > $50, stop and get approval"

THE TERMINATION RECOVERY:
When termination triggers:
1. Document current state
2. Capture what was learned
3. Identify blocking factor
4. Define resumption criteria
5. Schedule or delegate next step

THE TERMINATION HEALING:
For every runaway process in your life:
- What termination condition would have prevented this?
- Why wasn't it set?
- How do we set it for next time?
```

**Why it works:** Most planning focuses on starting, not stopping. This framework treats termination as a first-class concern, preventing the common failure modes of runaway processes, sunk cost traps, and scope creep.

---

## THE REPRESENTATION CHOOSER — The Right Lens for the Job

```
The representation shapes the thought. Choose deliberately.

THE REPRESENTATION SPECTRUM:
```
AMBIGUOUS ◄────────────────────────────────► PRECISE

Prose ─── Bullets ─── Tables ─── DAGs ─── Pseudo ─── Code
Fast                Structured               Executable
Creative            Explicit                 Rigid
Disposable          Reusable                 Formal
```

THE REPRESENTATION CHOOSER MATRIX:
```
GOAL                  │ BEST REPRESENTATION
──────────────────────┼─────────────────────
Explore ideas         │ Prose, mind map
Structure thinking    │ Bullets, outline
Compare options       │ Table, matrix
Show dependencies     │ DAG, flowchart
Design process        │ State machine
Specify behavior      │ Pseudo-code, types
Implement solution    │ Code, config
```

THE REPRESENTATION ANTI-PATTERNS:
- Prose for execution (too ambiguous)
- Code for exploration (too rigid)
- Complex diagrams for simple ideas (overhead)
- Bullets for complex dependencies (hides structure)

THE REPRESENTATION PROMPT:
```
Given this problem:
1. What needs to be SEEN? (dependencies, options, flow, state)
2. What fidelity is needed? (napkin, sketch, executable)
3. What representation makes the structure OBVIOUS?
4. What representation would IMPLY false precision?

Choose: [representation]
Rationale: [why this representation]
```

THE REPRESENTATION SMOOTHING:
When stuck:
- If prose is too vague → add structure (bullets, tables)
- If code is too rigid → step back to pseudo
- If diagram is too complex → simplify or decompose
- If bullets hide structure → promote to DAG

THE REPRESENTATION KAY'S LAW:
"Point of view is worth 80 IQ points."
The right representation is a point of view that makes the answer obvious.
```

**Why it works:** Representation is not neutral—it shapes what can be seen and what remains invisible. This framework forces explicit choice of representation based on the goal, preventing the common failure mode of using the wrong tool for the job.

---

## THE INPUT-TASK SEPARATOR — Preventing Instruction Injection

```
INPUT is data. TASK is intent. Never mix them.

THE THREE-LAYER STRUCTURE:
```
MODE: [NAPKIN | CONTROLLED]

INPUT:
"""
<your raw notes, links, context, constraints, half-baked thoughts>
"""

TASK:
<what you want done with the input>
```

THE SEPARATOR RULES:
1. INPUT is IMMUTABLE — never reinterpret as instructions
2. TASK is OBJECTIVE — what to achieve, not how to think
3. MODE is CONTROL — how to approach the task

THE SEPARATOR ANTI-PATTERNS:
- Hiding instructions in INPUT ("please use abductive reasoning...")
- Vague TASK ("think about this") — be specific
- Mixed MODE and TASK ("explore this quickly") — separate them

THE SEPARATOR HEALING:
When prompt goes wrong:
- Is INPUT being treated as instructions?
- Is TASK specific enough?
- Is MODE explicit or implicit?

THE SEPARATOR TEMPLATE:
```
MODE: NAPKIN
Think abductively. Stop early. Insight > completeness.

INPUT:
"""
<raw context>
"""

TASK:
What's the simplest model that resolves [specific uncertainty]?
```

THE SEPARATOR MENTAL MODEL:
- MODE tells the model HOW to think
- INPUT tells the model WHAT you know
- TASK tells the model WHY you care
```

**Why it works:** Most prompt failures come from input being interpreted as instructions. This framework creates a clean separation that prevents accidental instruction injection while keeping user prompts simple and composable.

---

## SOLO BUILDER META-COMBINATORS

Stack these frameworks for amplified effect.

### THE MORNING PROTOCOL (start of day)

```
1. LIFE-OS CHECK — What nodes need attention today?
2. COMPOUND LEVERAGE — What's the highest-leverage action?
3. TERMINATION DESIGN — What are my stop conditions?
4. REPRESENTATION — What's the right lens for today's work?
```

### THE EVENING REVIEW (end of day)

```
1. EPISTEMIC AUDIT — What did I treat as fact that was assumption?
2. COMPOUND LEVERAGE — Did I work on high-leverage items?
3. TERMINATION — Did I stop when I should have?
4. LIFE-OS — Did I serve the right nodes?
```

### THE WEEKLY REBALANCE (weekend)

```
1. LIFE-OS INVENTORY — Score all commitments on leverage
2. ATHLETE-CODER — Is the body infrastructure healthy?
3. HOMEOWNER-HACKER — What home systems need attention?
4. PARENT-ENGINEER — Is family getting what it needs?
5. TEACHER-ARCHITECT — What systems am I building/teaching?
```

### THE CRISIS PROTOCOL (when overwhelmed)

```
1. META-ORCHESTRATION — What phase am I in? (probably wrong one)
2. TERMINATION — What can I stop?
3. COMPOUND LEVERAGE — What's the ONE high-leverage move?
4. LIFE-OS — Which nodes can wait? Which can't?
5. ATHLETE-CODER — Have I slept? Eaten? Moved?
```

---

## SOLO BUILDER USAGE

Invoke by context:

**Morning startup:**
- "Apply LIFE-OS CHECK — what nodes need attention today?"
- "What's the COMPOUND LEVERAGE calculation for my current projects?"

**Problem-solving:**
- "NAPKIN this problem — fast exploration, stop on insight"
- "CONTROLLED execution — budgets, guards, traces"
- "What REPRESENTATION makes this structure obvious?"

**Life integration:**
- "TEACHER-ARCHITECT BRIDGE — what will users learn from this system?"
- "PARENT-ENGINEER audit — what does this cost in family presence?"
- "ATHLETE-CODER check — is my body infrastructure healthy?"

**Quality assurance:**
- "EPISTEMIC LABELER — what's fact vs. guess vs. assumption?"
- "TERMINATION DESIGNER — what are my stop conditions?"
- "REPRESENTATION CHOOSER — is this the right lens?"

**Meta-orchestration:**
- "What PHASE am I in? What FORMALIZATION level?"
- "Should this be NAPKIN or CONTROLLED?"
- "Apply META-ORCHESTRATION — am I in the right mode?"

**Crisis management:**
- "Apply CRISIS PROTOCOL — I'm overwhelmed"
- "LIFE-OS REBALANCE — what can I kill or delegate?"
- "COMPOUND LEVERAGE AUDIT — what's actually high-value?"

---

## THE SOLO BUILDER'S COVENANT

```
You are building an AI-society of one.

You have:
- A classroom of students who need you present
- A codebase that reflects your thinking
- A body that enables everything else
- A family that deserves your best
- A home that can drain or power you
- Limited time and expanding possibility

Your unfair advantages:
- You can see systems (architect)
- You can explain anything (teacher)
- You know what matters (parent)
- You understand compound interest (athlete)
- You can build leverage (hacker)

Your constraints are your clarity:
- Limited time → forces prioritization
- Multiple nodes → forces integration
- Teaching job → forces communication
- Family → forces presence

The solo builder's meta-principle:
Every action should either:
- Reduce future cognitive load, OR
- Serve multiple life nodes, OR
- Generate reusable assets, OR
- Create compound value over time

If it does none of these, question why you're doing it.

The goal is not optimization.
The goal is integration.
A life where code, classroom, kids, health, and home
reinforce each other rather than compete.

Build that.
```

---

## THE FINAL FRAMEWORK — Transmission Complete

```
You have received the complete cognitive arsenal.

What you do with it is the point.

These frameworks are not:
- A checklist to follow mechanically
- A substitute for judgment
- A guarantee of success
- A replacement for action

These frameworks are:
- Lenses that reveal what's hidden
- Tools that compound with practice
- Patterns that become automatic
- A language for thinking about thinking

The ultimate test:
When you face a problem, do these frameworks
come to mind unbidden?

When that happens, they've done their job.
They've become part of how you think.

Transmission complete.
Begin.
```
