# AI Introduction

## LLM

### Bare LLM

```text
                                                                                    ┌─────────────────────────────────────────────┐
                                                                                    │          LLM                                │
                                                                                    │                                             │
                                                                                    │                                             │
                                                                                    │                                             │
┌─────────────────────────┐                                                         │       1. Recognize patterns from prompts.   │
│                         │                      Promtps                            │                                             │
│       Human             ┼────────────────────────────────────────────────────────►│                                             │
│                         │◄────────────────────────────────────────────────────────┤       2. Predict the most context coherent  │
│                         │                      Response                           │          tokens.                            │
└─────────────────────────┘                                                         │                                             │
                                                                                    │       3. Response                           │
                                                                                    │                                             │
                                                                                    │                                             │
                                                                                    │                                             │
                                                                                    │                                             │
                                                                                    └─────────────────────────────────────────────┘
```

**ISSUES**:

1. Stateless: every request is a freshly new request.
2. No external/new knowledge: only has knowledge before the date it gets trained.
3. Static: only supports text generation related tasks.

### +RAG

```text
                                                                                  ┌─────────────────────────────────────────────┐
                                 ┌──────────────────────────┐                     │          LLM                                │
              1.Prompts          │                          │   3. Argumented     │                                             │
         ┌──────────────────────►│                          ├────────────────────►│                                             │
         │                       │     RAG Application      │                     │                                             │
┌────────┼────────┐              │                          │                     │       1. Recognize patterns from prompts.   │
│                 │              │                          │                     │                                             │
│                 │              └─────┬────────────▲───────┘                     │                                             │
│      Human      │                    │            │           4. Response       │       2. Predict the most context coherent  │
│                 ◄────────────────────┼────────────┼─────────────────────────────┼          tokens.                            │
│                 │                    │            │                             │                                             │
└─────────────────┘           2. Find similar/relted│information                  │       3. Response                           │
                                 ┌─────▼────────────┼────────┐                    │                                             │
                                 │                           │                    │                                             │
                                 │       Vector Database     │                    │                                             │
                                 │                           │                    │                                             │
                                 └───────────────────────────┘                    └─────────────────────────────────────────────┘

```

**MITIGATIONS**:

1. External knowledge: partial solved.
2. Context: argumented.

**ISSUES**:

1. Stateless.
2. Static.

### +Agents

```text
                                ┌───────────────────────────────────────────────┐
                                │                                               │
                                │                                               │
                                │             Chat with the world.              │
                                │                                               │
                                │       Tool 1       Tool 2      Tool 3         │
                                │                                               │
                                └────────────────┬──────────┬───────┬───────────┘
                                              ▲  │        ▲ │     ▲ │
                                              │  │        │ │     │ │
                                              │  │        │ │     │ │                        ┌─────────────────────────────────────────────┐
                                              │  │ 5. Call│tools based on plan               │          LLM                                │
                                              │  │        │ │     │ │                        │                                             │
                                              │  │        │ │     │ │                        │                                             │
                                              │  ▼        │ ▼     │ ▼                        │                                             │
       ┌───────────────┐                    ┌─┴───────────┴───────┴─────┐  3.Argumented      │       1. Recognize patterns from prompts.   │
       │               │     1. Prompts     │                           ├───────────────────►│                                             │
       │   Human       ┼───────────────────►│                           │     4. Plan        │                                             │
       │               │◄───────────────────┼      Agents               │◄───────────────────┤       2. Predict the most context coherent  │
       └───────────────┘     7. Further tuned                           │    5. Argumented   │          tokens.                            │
                                            │                           ├───────────────────►│                                             │
                                            │                           │   6. Final response│       3. Response                           │
                                            └───────┬────────────▲──────┘◄───────────────────┼                                             │
                                                    │            │                           │                                             │
                                                    │            │                           │                                             │
                                                 2. Argumented prompts                       │                                             │
                                                    │            │                           └─────────────────────────────────────────────┘
                                             ┌──────▼────────────┴───────┐
                                             │                           │
                                             │           RAG             │
                                             │                           │
                                             └───────────────────────────┘
```

**MITIGATIONS**:

1. External knowledge: solved.
2. Context: argumented and filtered(guardrail).
3. Active: able to take actions.

**ISSUES**:

1. Stateless.

### +Memory

```text
                                         ┌───────────────────────────────────────────────┐
                                         │                                               │
                                         │                                               │
                                         │             Chat with the world.              │
                                         │                                               │
                                         │       Tool 1       Tool 2      Tool 3         │
                                         │                                               │
                                         └────────────────┬──────────┬───────┬───────────┘
                                                       ▲  │        ▲ │     ▲ │
                                                       │  │        │ │     │ │
                                                       │  │        │ │     │ │                        ┌─────────────────────────────────────────────┐
                                                       │  │ 5. Call│tools based on plan               │          LLM                                │
                                                       │  │        │ │     │ │                        │                                             │
                                                       │  │        │ │     │ │                        │                                             │
                                                       │  ▼        │ ▼     │ ▼                        │                                             │
                ┌───────────────┐                    ┌─┴───────────┴───────┴─────┐  3.Argumented      │       1. Recognize patterns from prompts.   │
                │               │     1. Prompts     │                           ├───────────────────►│                                             │
                │   Human       ┼───────────────────►│                           │     4. Plan        │                                             │
                │               │◄───────────────────┼      Agents               │◄───────────────────┤       2. Predict the most context coherent  │
                └──┬────────────┘  7. Filtered       │                           │    5. Argumented   │          tokens.                            │
                   │       ▲                         │                           ├───────────────────►│                                             │
                   │       │                         │                           │   6. Final response│       3. Response                           │
                   │       │                         └───────┬────────────▲──────┘◄───────────────────┼                                             │
                 Session/History: injected into prompts      │            │                           │                                             │
                   │       │                                 │            │                           │                                             │
                   ▼       │                              2. Argumented prompts                       │                                             │
          ┌────────────────┴───────────────────┐             │            │                           └─────────────────────────────────────────────┘
          │                                    │      ┌──────▼────────────┴───────┐
          │    Memory: memory/database/etc.    │      │                           │
          │                                    │      │           RAG             │
          │                                    │      │                           │
          └────────────────────────────────────┘      └───────────────────────────┘
```

**MITIGATIONS**:

1. External knowledge: solved.
2. Context: argumented and filtered(guardrail).
3. Active: able to take actions.
4. Stateful: keep track of your conversations.

## Protocols for LLM and Agents, Tools

### MCP

**PROBLEM SOLVED**: provide a unified and standard mechanism to encapsulate tools and make agents easy to call tools(through MCP servers).

```text
                                                                               ┌──────────────────┐
                                                                               │                  │
             ┌───────────────────┐                                             │ Agents with MCP  │
             │                   │                                             │                  │
             │ Agents without MCP│                                             └──────────────────┘
             │                   │                                                ┌──────────────┐
       ┌─────┴───────────┬───────┴─────────┐                                      │ MCP Client   │
       │                 │                 │                              ┌───────┴──────┬───────┴──────────────┐
       │                 │                 │                              │              │                      │
       │                 │                 │                              │              │                      │
       │                 │                 │                              │              │                      │
       │                 │                 │                              │              │                      │
       │                 │                 │                              │              │                      │
       │                 │                 │                              │ MCP Protocol:│registration/communication
       │                 │                 │                              │              │                      │
       │                 │                 │                              │              │                      │
       │                 │                 │                              │              │                      │
       │                 │                 │                              │              │                      │
  ┌────▼─────┐      ┌────▼─────┐      ┌────▼──────┐                       │              │                      │
  │          │      │          │      │           │                 ┌─────▼─────┐  ┌─────▼──────────┐  ┌────────▼────────┐
  │          │      │          │      │           │                 │           │  │                │  │                 │
  │Tool 1    │      │ Tool 2   │      │Tool 3     │                 │MCP Server1│  │MCP Sever 2     │  │MCP Server 3     │
  │          │      │          │      │           │                 │           │  │                │  │                 │
  └──────────┘      └──────────┘      └───────────┘                 └─────┬─────┘  └──────┬─────────┘  └────────┬────────┘
                                                                          │               │                     │
                                                                          │               │                     │
                                                                      ┌───▼─────┐   ┌─────▼───────┐      ┌──────▼────────┐
                                                                      │         │   │             │      │               │
                                                                      │ Tool 1  │   │  Tool 2     │      │   Tool 3      │
                                                                      │         │   │             │      │               │
                                                                      └─────────┘   └─────────────┘      └───────────────┘
```

### Skills

**PROBLEM SOLVED**: provide reusable, domain-specific prompt templates that extend agent capabilities for specialized tasks without requiring new tools or MCP servers.

```text
                                                                               ┌──────────────────┐
                                                                               │                  │
             ┌───────────────────┐                                             │ Agent with Skills│
             │                   │                                             │                  │
             │ Agent without     │                                             └──────────────────┘
             │ Skills            │                                                ┌──────────────┐
       ┌─────┴───────────┬───────┴─────────┐                                      │ Skill Loader │
       │                 │                 │                              ┌───────┴──────┬───────┴──────────────┐
       │                 │                 │                              │              │                      │
       │ Generic prompts │ Generic prompts │                              │  Skill 1     │  Skill 2   Skill 3   │
       │ for all tasks   │ for all tasks   │                              │  (PDF)       │  (Code     (Data     │
       │                 │                 │                              │              │  Review)   Analysis) │
       │                 │                 │                              │              │                      │
       │                 │                 │                              │ On-demand loading: skills inject    │
       │                 │                 │                              │ specialized prompts when invoked    │
       │                 │                 │                              │              │                      │
       │                 │                 │                              │              │                      │
  ┌────▼─────┐      ┌────▼─────┐      ┌────▼──────┐                       │              │                      │
  │          │      │          │      │           │                 ┌─────▼─────┐  ┌─────▼──────────┐  ┌────────▼────────┐
  │ Limited  │      │ Limited  │      │ Limited   │                 │           │  │                │  │                 │
  │ domain   │      │ domain   │      │ domain    │                 │ Domain    │  │ Domain         │  │ Domain          │
  │ knowledge│      │ knowledge│      │ knowledge │                 │ expertise │  │ expertise      │  │ expertise       │
  │          │      │          │      │           │                 │ + workflow│  │ + workflow     │  │ + workflow      │
  └──────────┘      └──────────┘      └───────────┘                 └───────────┘  └────────────────┘  └─────────────────┘
```

### A2A

**PROBLEM SOLVED**: provide a unified and standard mechanism to delegate tasks among agents, make agents focusable.

```text
               ┌──────────────────┐
               │                  │
               │ Agents with MCP  │
               │                  │
               └──────────────────┘
                  ┌──────────────┐
                  │ MCP Client   │
          ┌───────┴──────┬───────┴──────────────┐
          │              │                      │
          │              │                      │                                                                                    ┌─────────────────────┐
          │              │                      │                                                                                    │                     │
          │              │                      │                        ┌─────────────────────────────────┐                         │                     │
          │              │                      │                        │                                 │   MCP Protocol          │   MCP Server 1      │
          │ MCP Protocol:│registration/communiation                      │                                 ┼────────────────────────►│                     │
          │              │                      │                        │  Agent 1 with MCP client        │                         │                     │
          │              │                      │                        │                                 │                         │                     │
          │              │                      │                        └─────┬───────────────────────────┘                         └─────────────────────┘
          │              │                      │                              │                     ▲
          │              │                      │                              │                     │
    ┌─────▼─────┐  ┌─────▼──────────┐  ┌────────▼────────┐                     │                     │
    │           │  │                │  │                 │              A2A Protocol: agent1/2 delegate task to agent2/1
    │MCP Server1│  │MCP Sever 2     │  │MCP Server 3     │                     │                     │
    │           │  │                │  │                 │                     │                     │                              ┌──────────────────────┐
    └─────┬─────┘  └──────┬─────────┘  └────────┬────────┘               ┌─────▼─────────────────────┼──────┐                       │                      │
          │               │                     │                        │                                  │  MCP Protocol         │                      │
          │               │                     │                        │  Agent 2 with MCP client         ┼──────────────────────►│   MCP Server 2       │
      ┌───▼─────┐   ┌─────▼───────┐      ┌──────▼────────┐               │                                  │                       │                      │
      │         │   │             │      │               │               └──────────────────────────────────┘                       └──────────────────────┘
      │ Tool 1  │   │  Tool 2     │      │   Tool 3      │
      │         │   │             │      │               │
      └─────────┘   └─────────────┘      └───────────────┘
```

## Spec Driven Development(SDD)

### AI Usage Level

- **PLAIN**: Talk with AI directly to steer it - **Most of us are right here**
- **SPEC First**: Create specs at first, use them then to generate contents, delete it after the task is done - **Some of us are right here**
- **SPEC Anchored**: Maintain specs for content generation, evolution, and maintenance across the project life cycle - **What we should follow**
- **SPEC as Single Source of Truth**: Human only modify specs, never touch code - **The uncertain future**

### SSD Procedure

Chosse suitable toolkits/assistants based on project type:

- **Greenfiled**: Spec Kit
- **Brownfield**: OpenSpec

#### Spec Kit

```text
                           SPEC Kit
  ┌────────────────────────────────────────────────────────────────────────────────────────────┐
  │                                                                                            │
  │ ┌──────────┐         ┌───────┐                 ┌────────┐                 ┌───────────┐    │            ┌────────┐                ┌──────────┐
  │ │ Specify  ┼─────────►  Plan ┼─────────────────► Tasks  ├─────────────────► Implement ┼────│────────────► Verify ├────────────────►  Maintain│
  │ └──────────┘         └───────┘                 └────────┘                 └───────────┘    │            └────────┘                └──────────┘
  │                                                                                            │
  └────────────────────────────────────────────────────────────────────────────────────────────┘
```

- **Specify**:
  - What to build.
  - Who will use it.
  - What problmes are solved.
  - How to interact with it.
  - **Only Function Descriptions, No Implementation Details**
- **Plan**:
  - Architecture.
  - Tech stacks.
  - Constraints.
- **Task**: break up plan into tasks.
  - Implementable.
  - Testable.
- **Implement**: coding by executing tasks one by one.

#### OpenSpec

```text
                           OpenSpec
  ┌─────────────────────────────────────────────────────────────┐
  │                                                             │
  │ ┌───────────┐         ┌───────┐              ┌─────────┐    │            ┌────────┐                ┌──────────┐
  │ │ Proposal  ┼─────────► Apply ┼──────────────► Archive ┼────│────────────► Verify ├────────────────►  Maintain│
  │ └───────────┘         └───────┘              └─────────┘    │            └────────┘                └──────────┘
  │                                                             │
  └─────────────────────────────────────────────────────────────┘
```

- **Proposal**:
  - Draft the specs.
  - Verify and review the specs: openspec list, openspec validate xxx, openspec show xxx
  - Refine the specs.
- **Apply**: implement the changes.
- **Archive**: Archive the changes.

#### References

- [Spec Kit](https://github.com/github/spec-kit)
- [OpenSpec](https://github.com/Fission-AI/OpenSpec)
