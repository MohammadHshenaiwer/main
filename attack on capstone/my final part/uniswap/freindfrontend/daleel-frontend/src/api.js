const BASE_URL = "http://localhost:8080/api";

export async function getActiveTrades() {
  const response = await fetch(`${BASE_URL}/trading/active`);
  if (!response.ok) throw new Error("Failed to fetch active trades");
  return response.json();
}

export async function acceptTrade(studentId, offerId) {
  const response = await fetch(`${BASE_URL}/trading/accept/${studentId}/${offerId}`, {
    method: "POST",
  });

  const text = await response.text();

  if (!response.ok) {
    throw new Error(text || "Failed to accept trade");
  }

  return text;
}

export async function getPortalSections() {
  const response = await fetch(`${BASE_URL}/portal-sections`);
  if (!response.ok) throw new Error("Failed to fetch portal sections");
  return response.json();
}

export async function getStudentSchedule(studentId) {
  const response = await fetch(`${BASE_URL}/student-schedule/${studentId}/detailed`);

  if (!response.ok) {
    throw new Error("Failed to fetch student schedule");
  }

  return response.json();
}

export async function addStudentSection(studentId, portalSectionId) {
  const response = await fetch(
    `${BASE_URL}/student-schedule/add?studentId=${studentId}&portalSectionId=${portalSectionId}`,
    {
      method: "POST",
    }
  );

  const text = await response.text();

  if (!response.ok) {
    throw new Error(text || "Failed to add section");
  }

  return text;
}

export async function removeStudentSection(studentId, portalSectionId) {
  const response = await fetch(
    `${BASE_URL}/student-schedule/remove?studentId=${studentId}&portalSectionId=${portalSectionId}`,
    {
      method: "DELETE",
    }
  );

  const text = await response.text();

  if (!response.ok) {
    throw new Error(text || "Failed to remove section");
  }

  return text;
}

export async function createTrade(studentId, offeredPortalSectionId, desiredPortalSectionId) {
  const response = await fetch(`${BASE_URL}/trading/create/${studentId}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      offeredPortalSectionId,
      desiredPortalSectionId,
    }),
  });

  const text = await response.text();

  if (!response.ok) {
    throw new Error(text || "Failed to create trade request");
  }

  return text;
}

export async function ensureWallet(studentId) {
  const response = await fetch(`${BASE_URL}/wallet/create/${studentId}`, {
    method: "POST",
  });

  const text = await response.text();

  if (!response.ok) {
    throw new Error(text || "Failed to create wallet");
  }

  return JSON.parse(text);
}

export async function cancelTrade(studentId, offerId) {
  const response = await fetch(`${BASE_URL}/trading/cancel/${studentId}/${offerId}`, {
    method: "POST",
  });

  const text = await response.text();

  if (!response.ok) {
    throw new Error(text || "Failed to cancel trade");
  }

  return text;
}