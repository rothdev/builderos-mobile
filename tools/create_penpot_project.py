#!/usr/bin/env python3
"""
Create a new Penpot project for BuilderOS Mobile app design.
Uses the Penpot API directly since write operations aren't exposed via MCP yet.
"""

import sys
import os

# Add the penpot-mcp-extended directory to Python path
penpot_mcp_path = "/Users/Ty/BuilderOS/global/penpot-mcp-extended"
if penpot_mcp_path not in sys.path:
    sys.path.insert(0, penpot_mcp_path)

from penpot_mcp.api.penpot_api import PenpotAPI


def create_builderos_mobile_project():
    """Create a new Penpot project for BuilderOS Mobile."""

    # Initialize API client
    print("🔌 Connecting to Penpot API at http://localhost:3449/api...")
    api = PenpotAPI(
        base_url="http://localhost:3449/api",
        debug=True
    )

    # Authenticate
    print("🔐 Authenticating...")
    try:
        auth_result = api.login_with_password()
        if not auth_result:
            print("❌ Authentication failed!")
            return None
    except Exception as e:
        print(f"❌ Authentication error: {e}")
        return None

    print("✅ Authentication successful!")

    # Create the project
    project_name = "BuilderOS Mobile"
    print(f"\n📁 Creating project: {project_name}")

    try:
        project = api.create_project(name=project_name)

        if "error" in project:
            print(f"❌ Error creating project: {project['error']}")
            return None

        project_id = project.get('id')
        team_name = project.get('team-name', 'Unknown')

        print(f"\n✅ Project created successfully!")
        print(f"   Project Name: {project_name}")
        print(f"   Project ID: {project_id}")
        print(f"   Team: {team_name}")
        print(f"   URL: http://localhost:3449/#/dashboard/team/{project.get('team-id')}/projects/{project_id}")

        return project

    except Exception as e:
        print(f"❌ Error creating project: {e}")
        import traceback
        traceback.print_exc()
        return None


if __name__ == "__main__":
    project = create_builderos_mobile_project()

    if project:
        print("\n✨ Next steps:")
        print("   1. Open Penpot at http://localhost:3449")
        print("   2. Navigate to the 'BuilderOS Mobile' project")
        print("   3. Start designing iOS app screens!")
        sys.exit(0)
    else:
        print("\n❌ Project creation failed")
        sys.exit(1)
