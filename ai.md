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
│                         │                      Prompts                            │                                             │
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

1. Stateless: every request is a fresh request.
2. No external/new knowledge: only has knowledge before the date it gets trained.
3. Static: only supports text generation related tasks.

### +RAG

```text
                                                                                  ┌─────────────────────────────────────────────┐
                                 ┌──────────────────────────┐                     │          LLM                                │
              1.Prompts          │                          │   3. Augmented      │                                             │
         ┌──────────────────────►│                          ├────────────────────►│                                             │
         │                       │     RAG Application      │                     │                                             │
┌────────┼────────┐              │                          │                     │       1. Recognize patterns from prompts.   │
│                 │              │                          │                     │                                             │
│                 │              └─────┬────────────▲───────┘                     │                                             │
│      Human      │                    │            │           4. Response       │       2. Predict the most context coherent  │
│                 ◄────────────────────┼────────────┼─────────────────────────────┤          tokens.                            │
│                 │                    │            │                             │                                             │
└─────────────────┘           2. Find similar/related│information                 │       3. Response                           │
                                 ┌─────▼────────────┼────────┐                    │                                             │
                                 │                           │                    │                                             │
                                 │       Vector Database     │                    │                                             │
                                 │                           │                    │                                             │
                                 └───────────────────────────┘                    └─────────────────────────────────────────────┘

```

**MITIGATION**:

1. External knowledge: partially solved.
2. Context: augmented.

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
       ┌───────────────┐                    ┌─┴───────────┴───────┴─────┐  3.Augmented       │       1. Recognize patterns from prompts.   │
       │               │     1. Prompts     │                           ├───────────────────►│                                             │
       │   Human       ┼───────────────────►│                           │     4. Plan        │                                             │
       │               │◄───────────────────┼      Agents               │◄───────────────────┤       2. Predict the most context coherent  │
       └───────────────┘     7. Response                                │    5. Tool results │          tokens.                            │
                                            │                           ├───────────────────►│                                             │
                                            │                           │   6. Final response│       3. Response                           │
                                            └───────┬────────────▲──────┘◄───────────────────┼                                             │
                                                    │            │                           │                                             │
                                                    │            │                           │                                             │
                                                 2. Augmented prompts                        │                                             │
                                                    │            │                           └─────────────────────────────────────────────┘
                                             ┌──────▼────────────┴───────┐
                                             │                           │
                                             │           RAG             │
                                             │                           │
                                             └───────────────────────────┘
```

**MITIGATION**:

1. External knowledge: solved.
2. Context: augmented and filtered (guardrail).
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
                ┌───────────────┐                    ┌─┴───────────┴───────┴─────┐  3.Augmented       │       1. Recognize patterns from prompts.   │
                │               │     1. Prompts     │                           ├───────────────────►│                                             │
                │   Human       ┼───────────────────►│                           │     4. Plan        │                                             │
                │               │◄───────────────────┼      Agents               │◄───────────────────┤       2. Predict the most context coherent  │
                └──┬────────────┘  7. Response       │                           │    5. Tool results │          tokens.                            │
                   │       ▲                         │                           ├───────────────────►│                                             │
                   │       │                         │                           │   6. Final response│       3. Response                           │
                   │       │                         └───────┬────────────▲──────┘◄───────────────────┼                                             │
                 Session/History: injected into prompts      │            │                           │                                             │
                   │       │                                 │            │                           │                                             │
                   ▼       │                              2. Augmented prompts                        │                                             │
          ┌────────────────┴───────────────────┐             │            │                           └─────────────────────────────────────────────┘
          │                                    │      ┌──────▼────────────┴───────┐
          │    Memory: memory/database/etc.    │      │                           │
          │                                    │      │           RAG             │
          │                                    │      │                           │
          └────────────────────────────────────┘      └───────────────────────────┘
```

**MITIGATION**:

1. External knowledge: solved.
2. Context: augmented and filtered (guardrail).
3. Active: able to take actions.
4. Stateful: keep track of your conversations.

## Protocols for LLM and Agents, Tools

### MCP

**PROBLEM SOLVED**: provides a unified and standard mechanism to encapsulate tools and make it easy for agents to call tools (through MCP servers).

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
  │Tool 1    │      │ Tool 2   │      │Tool 3     │                 │MCP Server1│  │MCP Server 2    │  │MCP Server 3     │
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

**PROBLEM SOLVED**: provide a unified and standard mechanism to enable agents to communicate and delegate tasks to each other.

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
          │ MCP Protocol:│registration/communication                     │                                 ┼────────────────────────►│                     │
          │              │                      │                        │  Agent 1 with MCP client        │                         │                     │
          │              │                      │                        │                                 │                         │                     │
          │              │                      │                        └─────┬───────────────────────────┘                         └─────────────────────┘
          │              │                      │                              │                     ▲
          │              │                      │                              │                     │
    ┌─────▼─────┐  ┌─────▼──────────┐  ┌────────▼────────┐                     │                     │
    │           │  │                │  │                 │              A2A Protocol: agent1/2 delegate task to agent2/1
    │MCP Server1│  │MCP Server 2    │  │MCP Server 3     │                     │                     │
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


