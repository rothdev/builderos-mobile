# Architecture Overview - Builder-System-Mobile

## System Architecture
- **Lane**: standard (production-ready)
- **Branch**: app (technology focus)
- **Targets**: ios_app
- **Integration**: Builder system capsule pattern

## Key Components
- Core functionality in `src/` directory
- Configuration and specifications in `spec/` directory  
- Documentation in `docs/` directory
- Operational artifacts in `ops/` and `runs/` directories

## Integration Points
- Builder system automation and monitoring
- MCP memory system for context persistence
- n8n workflows for automation integration
- Claude Code agent system for development

## Quality Architecture
- standard quality standards applied
- Comprehensive error handling and logging
- Integration with Builder monitoring and alerting
- Documentation and operational runbooks

## Technology Constraints
- Must integrate with Builder system patterns
- Follows established Builder conventions
- Compatible with Builder automation infrastructure
- Supports Builder's quality and security requirements
