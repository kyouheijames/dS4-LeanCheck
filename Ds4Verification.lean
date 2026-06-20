-- Root module for the dS4-LeanCheck verification library.
--
-- `Core`    : the framework (metric tensor, de Sitter constraints, holographic hypothesis).
-- `Example` : a concrete, hand-written instantiation that the harness can verify.
--             It also doubles as the seed/reference for the LLM generator loop.
import Ds4Verification.Core
import Ds4Verification.Example
