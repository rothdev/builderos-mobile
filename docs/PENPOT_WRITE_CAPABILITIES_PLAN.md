# Penpot MCP Write Capabilities Implementation Plan

## Current Status
- **Read-only MCP server**: Successfully lists projects, gets files, exports objects
- **Local Penpot instance**: Running on http://localhost:3449 (Docker dev environment)
- **Authentication**: Session-based with cookies (already logged in via browser)

## Implementation Strategy (Per Codex Recommendation)

### Phase 1: API Research & Testing
1. **Manual Network Capture** (IMMEDIATE NEXT STEP)
   - Open Penpot UI at http://localhost:3449 in browser
   - Open DevTools → Network tab
   - Create a new project manually
   - Capture the RPC request:
     - Endpoint URL
     - Request headers (cookies, content-type)
     - Request payload
     - Response structure
   - Repeat for "Create File" action
   - Document findings

2. **Alternative: Penpot Source Code Review**
   - Clone Penpot backend: https://github.com/penpot/penpot
   - Search for RPC command definitions
   - Find exact parameter requirements

### Phase 2: Extend MCP Server
1. **Add PenpotAPI methods**:
   ```python
   def create_project(self, name: str, team_id: Optional[str] = None) -> Dict[str, Any]:
       """Create a new Penpot project."""
       url = f"{self.base_url}/rpc/command/create-project"
       payload = {
           "name": name,
           "team-id": team_id or self.profile_id
       }
       response = self._make_authenticated_request('post', url, json=payload)
       return self._normalize_transit_response(response.json())
   
   def create_file(self, name: str, project_id: str, is_shared: bool = False) -> Dict[str, Any]:
       """Create a new file in a project."""
       url = f"{self.base_url}/rpc/command/create-file"
       payload = {
           "name": name,
           "project-id": project_id,
           "is-shared": is_shared
       }
       response = self._make_authenticated_request('post', url, json=payload)
       return self._normalize_transit_response(response.json())
   ```

2. **Add MCP Tools**:
   ```python
   @self.mcp.tool()
   def create_project(name: str, team_id: str = None) -> dict:
       """Create a new Penpot project."""
       try:
           project = self.api.create_project(name=name, team_id=team_id)
           return {"project": project}
       except Exception as e:
           return self._handle_api_error(e)
   ```

3. **Install locally**:
   ```bash
   cd /Users/Ty/BuilderOS/global/penpot-mcp-extended
   pip install -e .  # editable install
   ```

### Phase 3: Testing
1. Test via Python script
2. Test via MCP tools in Claude Code
3. Create BuilderOS Mobile project using new tools

## Next Actions
1. **IMMEDIATE**: Manually capture network traffic (5 minutes)
2. Implement create_project and create_file methods (15 minutes)
3. Test and iterate (10 minutes)
4. Document final API in capsule docs (5 minutes)

**Total estimated time**: ~35 minutes

## API Capture Template
```
### Create Project
**Endpoint:** POST /api/rpc/command/???
**Authentication:** Cookie: auth-token=???

**Request Payload:**
{
  "...": "..."
}

**Response:**
{
  "...": "..."
}
```
