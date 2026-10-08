const API_ROOT = import.meta.env.VITE_API_URL ?? '';

export class ApiError extends Error {
  constructor(message: string, public readonly status: number) {
    super(message);
    this.name = 'ApiError';
  }
}

async function csrfToken() {
  const response = await fetch(`${API_ROOT}/api/auth/csrf`, { credentials: 'include' });
  if (!response.ok) throw new ApiError('Could not initialize a secure session.', response.status);
  const payload = await response.json() as { token: string };
  return payload.token;
}

export async function api<T>(path: string, init: RequestInit = {}): Promise<T> {
  const headers = new Headers(init.headers);
  if (init.body && !headers.has('Content-Type')) headers.set('Content-Type', 'application/json');
  headers.set('Accept', 'application/json');
  const method = (init.method ?? 'GET').toUpperCase();
  if (!['GET', 'HEAD', 'OPTIONS', 'TRACE'].includes(method) && path !== '/api/auth/login') {
    headers.set('X-XSRF-TOKEN', await csrfToken());
  }

  let response: Response;
  try {
    response = await fetch(`${API_ROOT}${path}`, { ...init, headers, credentials: 'include' });
  } catch {
    throw new Error('Cannot reach the logistics API. Check that the backend is running on port 8080.');
  }

  if (!response.ok) {
    const payload = await response.json().catch(() => null) as { message?: string; error?: string } | null;
    throw new ApiError(payload?.message || payload?.error || `Request failed (${response.status})`, response.status);
  }

  if (response.status === 204) return undefined as T;
  return response.json() as Promise<T>;
}

export const get = <T>(path: string) => api<T>(path);
export const post = <T>(path: string, value: unknown) => api<T>(path, { method: 'POST', body: JSON.stringify(value) });
export const put = <T>(path: string, value: unknown) => api<T>(path, { method: 'PUT', body: JSON.stringify(value) });
export const patch = <T>(path: string, value: unknown) => api<T>(path, { method: 'PATCH', body: JSON.stringify(value) });
export const remove = (path: string) => api<void>(path, { method: 'DELETE' });

export async function downloadReportPdf(path: string, filename: string): Promise<void> {
  const headers = new Headers();
  headers.set('Accept', 'application/pdf');

  let response: Response;
  try {
    response = await fetch(`${API_ROOT}${path}`, {
      method: 'GET',
      headers,
      credentials: 'include',
    });
  } catch {
    throw new Error('Cannot reach the logistics API. Check that the backend is running on port 8080.');
  }

  if (!response.ok) {
    const payload = await response.json().catch(() => null) as { message?: string; error?: string } | null;
    throw new ApiError(payload?.message || payload?.error || `PDF download failed (${response.status})`, response.status);
  }

  const blob = await response.blob();
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(url);
}

