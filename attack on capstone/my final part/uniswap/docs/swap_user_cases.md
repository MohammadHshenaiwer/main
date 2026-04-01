# UniSwap User Cases

This guide gives exact test steps: who logs in, what to click, and expected result.

## Before You Start

1. Run seed script: `data/test cases.sql`
2. Start backend and frontend.
3. Login identifier = student number, password = any non-empty text.
4. If a case changes schedule (accepted swap), rerun `data/test cases.sql` before the next case.

Direct request meaning in this project:

- A direct request is a targeted offer (`targetStudentId`) that only one student can accept.

## Test Users

- `900001` / `22000001` -> Year 4
- `900002` / `22000002` -> Year 4
- `900003` / `22000003` -> Year 4
- `900004` / `22000004` -> Year 4
- `900005` / `23000001` -> Year 3
- `900006` / `23000002` -> Year 3
- `900007` / `24000001` -> Year 2
- `900008` / `24000002` -> Year 2
- `900009` / `25000001` -> Year 1
- `900010` / `25000002` -> Year 1
- `900011` / `23000011` -> Year 3 (multi-offer/direct-request cases)
- `900012` / `22000012` -> Year 4 (target student for direct-request case)

## Case-by-Case Steps

### 1) Valid swap is accepted

1. Login `22000001`.
2. Go to `Schedule` -> click `Trade` on `Database Programming - Section 1`.
3. Request `Database Programming - Section 2` and submit offer.
4. Login `22000002`.
5. Go to `Trading` -> accept that offer.
6. Expected: swap is completed successfully.

### 2) Time-conflicting target section is rejected

1. Login `22000003`.
2. Go to `Schedule` -> click `Trade` on `Capstone Project I - Section 1`.
3. Try to request `Database Programming - Section 1`.
4. Expected: blocked with time conflict message.

### 3) Already-completed target course is rejected on accept

1. Login `22000002`.
2. Create offer: `Capstone Project I - Section 1` -> `Systems Programming - Section 1`.
3. Login `22000001`.
4. Go to `Trading` -> try to accept that offer.
5. Expected: blocked because accepter already completed `Capstone Project I`.

### 4) Missing prerequisite is rejected on accept

1. Login `22000001`.
2. Create offer: `Capstone Project II - Section 1` -> `Database Programming - Section 2`.
3. Login `22000002`.
4. Go to `Trading` -> try to accept that offer.
5. Expected: blocked because prerequisite is not completed.

### 5) Duplicate pending request is rejected

UI does not expose send-request flow directly, so use browser console once.

1. Login `22000002` and create offer: `Database Programming - Section 2` -> `Internet of Things - Section 1`.
2. Open browser console and run:

```js
const api = "http://localhost:8080/api";
const j = async (r) => { const x = await r.json(); console.log(x); return x; };

// find open offer created by user 900002
const myOffers = await j(await fetch(`${api}/swaps/offers/my?studentId=900002`));
const offerId = myOffers.data.find(o => o.status === "OPEN")?.offerId;

// send once
await j(await fetch(`${api}/swaps/requests`, {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ offerId, senderId: 900001, receiverId: 900002, senderSectionId: 81 })
}));

// send exact same request again (should fail)
await j(await fetch(`${api}/swaps/requests`, {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ offerId, senderId: 900001, receiverId: 900002, senderSectionId: 81 })
}));
```

3. Expected: first request succeeds, second request is rejected as duplicate/pending.

### 6) Offering a completed course is rejected

1. Login `22000004`.
2. Go to `Schedule` -> click `Trade` on `Database Programming - Section 2`.
3. Pick any wanted section and submit.
4. Expected: blocked because this course is already completed for this user.

### 7) Directed offer can only be accepted by targeted student

1. Login `23000011`.
2. Go to `Schedule` -> click `Trade` on `Database Programming - Section 1`.
3. In the blue box, enter `22000012` (student number) or `900012` (student ID) in `Direct request to student ID (optional)`.
4. Choose requested section `Database Programming - Section 2` and submit.
5. Login `22000003` and open `Trading`.
6. Expected: this directed offer is not available for `22000003`.
7. Login `22000012` and open `Trading`.
8. Accept the directed offer.
9. Expected: accepted for target student only.

### 8) Same offered section can target multiple wanted sections

1. Login `23000011`.
2. Create offer A: `Database Programming - Section 1` -> `Database Programming - Section 2`.
3. Create offer B: `Database Programming - Section 1` -> `Cloud Computing - Section 2`.
4. Expected: both offers are allowed.

### 9) Exact duplicate offer pair is rejected

1. Login `23000011`.
2. Create offer: `Database Programming - Section 1` -> `Database Programming - Section 2`.
3. Repeat same exact offer again.
4. Expected: second one is rejected.

### 10) Accepting one swap cancels other dependent requests

1. Login `22000002` and create offer O1: `Database Programming - Section 2` -> `Internet of Things - Section 1`.
2. Login `22000004` and create offer O2: `Systems Programming - Section 2` -> `Internet of Things - Section 1`.
3. From console, user `900001` sends request to O1 and O2 using same `Internet of Things - Section 1` as sender section:

```js
const api = "http://localhost:8080/api";
const show = async (p) => (await (await fetch(`${api}${p}`)).json());

const o1 = (await show('/swaps/offers/my?studentId=900002')).data.find(o => o.status === 'OPEN')?.offerId;
const o2 = (await show('/swaps/offers/my?studentId=900004')).data.find(o => o.status === 'OPEN')?.offerId;

await fetch(`${api}/swaps/requests`, {
  method:'POST', headers:{'Content-Type':'application/json'},
  body: JSON.stringify({ offerId:o1, senderId:900001, receiverId:900002, senderSectionId:81 })
}).then(r=>r.json()).then(console.log);

await fetch(`${api}/swaps/requests`, {
  method:'POST', headers:{'Content-Type':'application/json'},
  body: JSON.stringify({ offerId:o2, senderId:900001, receiverId:900004, senderSectionId:81 })
}).then(r=>r.json()).then(console.log);
```

4. Login `22000002` -> `My Swaps` -> accept request for O1.
5. Login `22000001` -> `My Swaps` -> check sent requests.
6. Expected: accepted one is `ACCEPTED`, other dependent one becomes `CANCELLED`.

## Cleanup

After testing, run:

- `docs/sql/cleanup/test_users_swap_cleanup.sql`

## Rule Mapping In Code

- Offer rules: `src/main/java/com/university/swap/service/SwapOfferService.java`
- Request rules and dependency cleanup: `src/main/java/com/university/swap/service/SwapRequestService.java`
- Offer duplicate-pair query: `src/main/java/com/university/swap/repository/SwapOfferRepository.java`
- Enrollment duplicate safety and startup cleanup: `src/main/java/com/university/swap/repository/EnrollmentRepository.java`, `src/main/java/com/university/swap/service/EnrollmentService.java`
