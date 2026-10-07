const API_ROOT = import.meta.env.VITE_API_URL ?? '';

export async function api<T>(path: string, init: RequestInit = {}): Promise<T> {
  const headers = new Headers(init.headers);
  if (init.body && !headers.has('Content-Type')) headers.set('Content-Type', 'application/json');
  headers.set('Accept', 'application/json');

  let response: Response;
  try {
    response = await fetch(`${API_ROOT}${path}`, { ...init, headers });
  } catch {
    throw new Error('Cannot reach the logistics API. Check that the backend is running on port 8080.');
  }

  if (!response.ok) {
    const payload = await response.json().catch(() => null) as { message?: string; error?: string } | null;
    throw new Error(payload?.message || payload?.error || `Request failed (${response.status})`);
  }

  if (response.status === 204) return undefined as T;
  return response.json() as Promise<T>;
}

export const get = <T>(path: string) => api<T>(path);
export const post = <T>(path: string, value: unknown) => api<T>(path, { method: 'POST', body: JSON.stringify(value) });
export const put = <T>(path: string, value: unknown) => api<T>(path, { method: 'PUT', body: JSON.stringify(value) });
export const patch = <T>(path: string, value: unknown) => api<T>(path, { method: 'PATCH', body: JSON.stringify(value) });
export const remove = (path: string) => api<void>(path, { method: 'DELETE' });
