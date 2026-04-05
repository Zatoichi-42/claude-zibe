# Open Questions — Ask Before Every Major Decision
**There are no edge cases, only certainties.**
## Lifecycle
- What happens if this session dies mid-implementation?
- Who or what restarts this work if the session is killed?
- If the Stop hook doesn't fire (hard kill), what state is lost?
## Observability
- Can the human see what's happening without typing commands?
- If this runs at 3am, how does the human know what happened?
## Autonomy
- Does this require human input to proceed?
- Are there permission prompts that will block autonomous execution?
## Architecture
- Are we assuming something exists that might not?
- Does this work with zero tests? Zero commits? Empty project?
- Could a simpler solution work?
## Human
- What if the human doesn't review EVOLUTION.md for a week?
- Is CLAUDE.md under 25 rules?
## Integration
- Does this change break any existing hooks?
- Will this survive a /compact and session restart?
- Is this committed to git or only in transient files?
