const BASE_URL = "http://localhost:8080/api";

// ── Helper to extract data from ApiResponse wrapper ──
async function apiCall(url, options = {}) {
  const response = await fetch(url, options);
  const json = await response.json();

  if (!response.ok || json.success === false) {
    throw new Error(json.message || "Request failed");
  }

  return json.data;
}

// ── Student ───────────────────────────────────────────
export async function verifyStudent(studentId) {
  return apiCall(`${BASE_URL}/students/${studentId}`);
}

export async function getCompletedCourses(studentId) {
  return apiCall(`${BASE_URL}/students/${studentId}/completions`);
}

// ── Enrollments ───────────────────────────────────────
export async function getStudentSchedule(studentId) {
  return apiCall(`${BASE_URL}/enrollments/my?studentId=${studentId}`);
}

export async function addStudentSection(studentId, sectionId) {
  return apiCall(
    `${BASE_URL}/enrollments/add?studentId=${studentId}&sectionId=${sectionId}`,
    { method: "POST" }
  );
}

export async function removeStudentSection(studentId, sectionId) {
  return apiCall(
    `${BASE_URL}/enrollments/remove?studentId=${studentId}&sectionId=${sectionId}`,
    { method: "DELETE" }
  );
}

// ── Sections ──────────────────────────────────────────
export async function getAllSections() {
  return apiCall(`${BASE_URL}/sections`);
}

// ── Swap Offers ───────────────────────────────────────
export async function getOpenOffers(studentId) {
  return apiCall(`${BASE_URL}/swaps/offers?studentId=${studentId}`);
}

export async function getMyOffers(studentId) {
  return apiCall(`${BASE_URL}/swaps/offers/my?studentId=${studentId}`);
}

export async function createOffer(studentId, haveSectionId, wantSectionId, swapType = "SECTION_SWAP", targetStudentId = null) {
  const body = { studentId: Number(studentId), haveSectionId, wantSectionId, swapType };
  if (targetStudentId) body.targetStudentId = Number(targetStudentId);

  return apiCall(`${BASE_URL}/swaps/offers`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
}

export async function cancelOffer(studentId, offerId) {
  return apiCall(`${BASE_URL}/swaps/offers/${offerId}?studentId=${studentId}`, {
    method: "DELETE",
  });
}

// ── Swap Requests ─────────────────────────────────────
export async function acceptDirectTrade(studentId, offerId, offeredSectionId) {
  return apiCall(`${BASE_URL}/swaps/requests/accept-direct`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      offerId,
      accepterStudentId: Number(studentId),
      offeredSectionId,
    }),
  });
}

export async function getIncomingRequests(studentId) {
  return apiCall(`${BASE_URL}/swaps/requests/incoming?studentId=${studentId}`);
}

export async function getSentRequests(studentId) {
  return apiCall(`${BASE_URL}/swaps/requests/sent?studentId=${studentId}`);
}

export async function acceptRequest(requestId, studentId) {
  return apiCall(`${BASE_URL}/swaps/requests/${requestId}/accept?studentId=${studentId}`, {
    method: "POST",
  });
}

export async function rejectRequest(requestId, studentId) {
  return apiCall(`${BASE_URL}/swaps/requests/${requestId}/reject?studentId=${studentId}`, {
    method: "POST",
  });
}

export async function cancelRequest(requestId, studentId) {
  return apiCall(`${BASE_URL}/swaps/requests/${requestId}?studentId=${studentId}`, {
    method: "DELETE",
  });
}
