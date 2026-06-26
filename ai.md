---
tags: [ai, cheatsheet]
aliases: ["AI", "LLM", "agents"]
type: cheatsheet
---
# AI Introduction

## LLM

### Bare LLM
```mermaid
flowchart LR
    Human[Human]
    LLM["LLM<br>1. Recognize patterns from prompts.<br>2. Predict the most context coherent tokens.<br>3. Response"]
    Human -- Prompts --> LLM
    LLM -- Response --> Human
```
**ISSUES**:

1. Stateless: every request is a fresh request.
2. No external/new knowledge: only has knowledge before the date it gets trained.
3. Static: only supports text generation related tasks.

### +RAG

```mermaid
flowchart LR
    Human[Human]
    RAG[RAG Application]
    LLM["LLM<br>1. Recognize patterns from prompts.<br>2. Predict the most context coherent tokens.<br>3. Response"]
    DB[("Vector Database<br>(embeddings)")]
    Human -- "1. Prompts" --> RAG
    RAG -- "3. Augmented prompt" --> LLM
    LLM -- "4. Response" --> Human
    RAG <-->|"2. Find similar/related info"| DB
```

**MITIGATION**:

1. External knowledge: partially solved.
2. Context: augmented.

**ISSUES**:

1. Stateless.
2. Static.

### +Agents

```mermaid
flowchart LR
    Human[Human]
    Agents["Agents<br>(Chat with the world)"]
    LLM["LLM<br>1. Recognize patterns from prompts.<br>2. Predict the most context coherent tokens.<br>3. Response"]
    RAG[RAG]
    T1[Tool 1]
    T2[Tool 2]
    T3[Tool 3]
    Human -- "1. Prompts" --> Agents
    Agents -- "3. Augmented prompt" --> LLM
    LLM -- "4. Plan / 6. Final response" --> Agents
    Agents -- "5. Tool results" --> LLM
    Agents -- "7. Response" --> Human
    Agents <-->|"2. Augmented prompts"| RAG
    Agents <-->|"5. Call tools based on plan"| T1
    Agents <-->|"5. Call tools based on plan"| T2
    Agents <-->|"5. Call tools based on plan"| T3
```

**MITIGATION**:

1. External knowledge: solved.
2. Context: augmented and filtered (guardrail).
3. Active: able to take actions.

**ISSUES**:

1. Stateless.

### +Memory

```mermaid
flowchart LR
    Human[Human]
    Agents["Agents<br>(Chat with the world)"]
    LLM["LLM<br>1. Recognize patterns from prompts.<br>2. Predict the most context coherent tokens.<br>3. Response"]
    RAG[RAG]
    Memory[("Memory<br>(memory / database / etc.)")]
    T1[Tool 1]
    T2[Tool 2]
    T3[Tool 3]
    Human -- "1. Prompts" --> Agents
    Agents -- "3. Augmented prompt" --> LLM
    LLM -- "4. Plan / 6. Final response" --> Agents
    Agents -- "5. Tool results" --> LLM
    Agents -- "7. Response" --> Human
    Agents <-->|"2. Augmented prompts"| RAG
    Agents <-->|"5. Call tools based on plan"| T1
    Agents <-->|"5. Call tools based on plan"| T2
    Agents <-->|"5. Call tools based on plan"| T3
    Human <-->|"Session/History: injected into prompts"| Memory
```

**MITIGATION**:

1. External knowledge: solved.
2. Context: augmented and filtered (guardrail).
3. Active: able to take actions.
4. Stateful: keep track of your conversations.

## Protocols for LLM and Agents, Tools

### MCP

**PROBLEM SOLVED**: provides a unified and standard mechanism to encapsulate tools and make it easy for agents to call tools (through MCP servers).

```mermaid
flowchart LR
    subgraph Before["Without MCP"]
        direction TB
        A1[Agent]
        T1a[Tool 1]
        T2a[Tool 2]
        T3a[Tool 3]
        A1 -- "custom integration" --> T1a
        A1 -- "custom integration" --> T2a
        A1 -- "custom integration" --> T3a
    end
    subgraph After["With MCP"]
        direction TB
        A2[Agent]
        C[MCP Client]
        S1[MCP Server 1]
        S2[MCP Server 2]
        S3[MCP Server 3]
        T1b[Tool 1]
        T2b[Tool 2]
        T3b[Tool 3]
        A2 --> C
        C <-->|"MCP Protocol: registration/communication"| S1
        C <-->|"MCP Protocol: registration/communication"| S2
        C <-->|"MCP Protocol: registration/communication"| S3
        S1 --> T1b
        S2 --> T2b
        S3 --> T3b
    end
```

### Skills

**PROBLEM SOLVED**: provide reusable, domain-specific prompt templates that extend agent capabilities for specialized tasks without requiring new tools or MCP servers.

```mermaid
flowchart LR
    subgraph Before["Without Skills"]
        direction TB
        A1[Agent]
        T1a["Task 1<br>Generic prompts<br>Limited domain knowledge"]
        T2a["Task 2<br>Generic prompts<br>Limited domain knowledge"]
        T3a["Task 3<br>Generic prompts<br>Limited domain knowledge"]
        A1 --> T1a
        A1 --> T2a
        A1 --> T3a
    end
    subgraph After["With Skills"]
        direction TB
        A2[Agent]
        SL["Skill Loader<br>(on-demand loading)"]
        S1["Skill 1 (PDF)<br>Domain expertise + workflow"]
        S2["Skill 2 (Code Review)<br>Domain expertise + workflow"]
        S3["Skill 3 (Data Analysis)<br>Domain expertise + workflow"]
        A2 --> SL
        SL --> S1
        SL --> S2
        SL --> S3
    end
```

### A2A

**PROBLEM SOLVED**: provide a unified and standard mechanism to enable agents to communicate and delegate tasks to each other.

```mermaid
flowchart LR
    subgraph Agent1["Agent 1"]
        direction TB
        A1[Agent with MCP]
        C1[MCP Client]
        S1[MCP Server 1]
        A1 --> C1
        C1 <-->|"MCP Protocol"| S1
    end
    subgraph Agent2["Agent 2"]
        direction TB
        A2[Agent with MCP]
        C2[MCP Client]
        S2[MCP Server 2]
        A2 --> C2
        C2 <-->|"MCP Protocol"| S2
    end
    C1 <-->|"A2A Protocol: delegate task to other agent"| C2
```


