from supabase import create_client, Client
import os

_client: Client | None = None

def get_supabase() -> Client:
    global _client
    if _client is None:
        url = os.environ.get('SUPABASE_URL')
        key = os.environ.get('SUPABASE_SERVICE_KEY')
        if not url or not key:
            raise RuntimeError("SUPABASE_URL e SUPABASE_SERVICE_KEY devem estar configurados.")
        _client = create_client(url, key)
    return _client