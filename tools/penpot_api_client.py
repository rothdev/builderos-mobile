#!/usr/bin/env python3
"""
Penpot API Client for programmatic file creation
Uses the local Penpot instance RPC API
"""

import requests
import json
import uuid
from typing import Dict, Any

class PenpotClient:
    def __init__(self, base_url="http://localhost:3449", access_token=None):
        self.base_url = base_url
        self.session = requests.Session()
        self.profile_id = None
        self.access_token = access_token

        # Set authorization header if token provided
        if access_token:
            self.session.headers.update({
                "Authorization": f"Token {access_token}"
            })

    def login(self, email: str, password: str) -> bool:
        """Login to Penpot and establish session (deprecated - use access token instead)"""
        url = f"{self.base_url}/api/rpc/command/login"

        payload = {
            "email": email,
            "password": password
        }

        try:
            response = self.session.post(url, json=payload)
            print(f"Login response status: {response.status_code}")

            if response.status_code == 200:
                return True
            return False
        except Exception as e:
            print(f"Login error: {e}")
            return False

    def create_file(self, project_id: str, name: str) -> Dict[str, Any]:
        """Create a new file in a project"""
        url = f"{self.base_url}/api/rpc/command/create-file"

        payload = {
            "projectId": project_id,
            "name": name
        }

        try:
            response = self.session.post(url, json=payload)
            print(f"Create file response status: {response.status_code}")
            print(f"Create file response: {response.text[:500]}")

            if response.status_code == 200:
                return response.json()
            return None
        except Exception as e:
            print(f"Create file error: {e}")
            return None

    def get_projects(self) -> list:
        """Get list of projects"""
        url = f"{self.base_url}/api/rpc/command/get-projects"

        try:
            response = self.session.post(url)
            print(f"Get projects response status: {response.status_code}")

            if response.status_code == 200:
                return response.json()
            return []
        except Exception as e:
            print(f"Get projects error: {e}")
            return []


if __name__ == "__main__":
    # Test the client with access token
    ACCESS_TOKEN = "builderos-api-token-7134681765f25624851cde46ce7996bd"
    client = PenpotClient(access_token=ACCESS_TOKEN)

    print("=== Testing Penpot API Client with Access Token ===\n")

    # Try to get projects
    print("1. Fetching projects...")
    projects = client.get_projects()
    print(f"Projects: {projects}\n")

    # Try to create a file
    print("2. Creating test file...")
    project_id = "4c46a10f-a510-8112-8006-fefcf0abd38d"  # BuilderOS Mobile App
    file_result = client.create_file(project_id, "API Test File - iOS Dashboard")
    if file_result:
        print(f"✓ File created successfully!")
        print(f"  File ID: {file_result.get('id')}")
        print(f"  File name: {file_result.get('name')}")
    else:
        print("✗ File creation failed")
