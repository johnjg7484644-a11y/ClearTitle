;; Green Certification Contract
;; Clarity v2
;; Manages registration, verification, and expiration of green building certifications

(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-INVALID-CERT-ID u101)
(define-constant ERR-CERT-EXPIRED u102)
(define-constant ERR-CERT-NOT-FOUND u103)
(define-constant ERR-INVALID-STATUS u104)
(define-constant ERR-INVALID-TIMESTAMP u105)
(define-constant ERR-INVALID-PROPERTY u106)
(define-constant ERR-ZERO-ADDRESS u107)
(define-constant ERR-ALREADY-REGISTERED u108)

;; Contract metadata
(define-constant CONTRACT-NAME "ClearTitle Green Certification")
(define-constant CERT-ISSUER "LEED") ;; Example issuer, configurable
(define-constant STATUS-ACTIVE u1)
(define-constant STATUS-REVOKED u2)
(define-constant STATUS-EXPIRED u3)

;; Admin and contract state
(define-data-var admin principal tx-sender)
(define-data-var paused bool false)
(define-data-var cert-counter uint u0)

;; Certification data structure
(define-map certifications
  { cert-id: uint }
  {
    property-id: uint,
    issuer: (string-ascii 32),
    status: uint,
    issue-timestamp: uint,
    expiry-timestamp: uint,
    owner: principal,
    metadata: (string-ascii 256)
  }
)

;; Audit trail for certification changes
(define-map audit-trail
  { cert-id: uint, audit-id: uint }
  {
    timestamp: uint,
    action: (string-ascii 64),
    actor: principal,
    details: (string-ascii 256)
  }
)

;; Track audit entries per certification
(define-map audit-counter { cert-id: uint } uint)

;; Private helper: is-admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin))
)

;; Private helper: ensure not paused
(define-private (ensure-not-paused)
  (asserts! (not (var-get paused)) (err ERR-PAUSED))
)

;; Private helper: validate timestamp
(define-private (is-valid-timestamp (timestamp uint))
  (and (> timestamp u0) (<= timestamp block-height))
)

;; Private helper: validate status
(define-private (is-valid-status (status uint))
  (or (is-eq status STATUS-ACTIVE) (is-eq status STATUS-REVOKED) (is-eq status STATUS-EXPIRED))
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (is-eq new-admin 'SP000000000000000000002Q6VF78)) (err ERR-ZERO-ADDRESS))
    (var-set admin new-admin)
    (ok true)
  )
)

;; Pause/unpause the contract
(define-public (set-paused (pause bool))
  (begin
    (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
    (var-set paused pause)
    (ok pause)
  )
)

;; Register a new green certification
(define-public (register-certification
  (property-id uint)
  (issuer (string-ascii 32))
  (issue-timestamp uint)
  (expiry-timestamp uint)
  (owner principal)
  (metadata (string-ascii 256)))
  (begin
    (ensure-not-paused)
    (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (is-eq owner 'SP000000000000000000002Q6VF78)) (err ERR-ZERO-ADDRESS))
    (asserts! (> property-id u0) (err ERR-INVALID-PROPERTY))
    (asserts! (is-valid-timestamp issue-timestamp) (err ERR-INVALID-TIMESTAMP))
    (asserts! (> expiry-timestamp issue-timestamp) (err ERR-INVALID-TIMESTAMP))
    (let ((cert-id (+ (var-get cert-counter) u1)))
      (asserts! (is-none (map-get? certifications { cert-id: cert-id })) (err ERR-ALREADY-REGISTERED))
      (map-set certifications
        { cert-id: cert-id }
        {
          property-id: property-id,
          issuer: issuer,
          status: STATUS-ACTIVE,
          issue-timestamp: issue-timestamp,
          expiry-timestamp: expiry-timestamp,
          owner: owner,
          metadata: metadata
        }
      )
      (map-set audit-trail
        { cert-id: cert-id, audit-id: u1 }
        {
          timestamp: block-height,
          action: "cert-registered",
          actor: tx-sender,
          details: metadata
        }
      )
      (map-set audit-counter { cert-id: cert-id } u1)
      (var-set cert-counter cert-id)
      (ok cert-id)
    )
  )
)

;; Update certification status
(define-public (update-cert-status (cert-id uint) (new-status uint))
  (begin
    (ensure-not-paused)
    (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-valid-status new-status) (err ERR-INVALID-STATUS))
    (match (map-get? certifications { cert-id: cert-id })
      cert
      (begin
        (asserts! (<= block-height (get expiry-timestamp cert)) (err ERR-CERT-EXPIRED))
        (map-set certifications
          { cert-id: cert-id }
          (merge cert { status: new-status })
        )
        (let ((audit-id (+ (default-to u0 (map-get? audit-counter { cert-id: cert-id })) u1)))
          (map-set audit-trail
            { cert-id: cert-id, audit-id: audit-id }
            {
              timestamp: block-height,
              action: (if (is-eq new-status STATUS-REVOKED) "cert-revoked" "cert-expired"),
              actor: tx-sender,
              details: "Status updated"
            }
          )
          (map-set audit-counter { cert-id: cert-id } audit-id)
          (ok true)
        )
      )
      (err ERR-CERT-NOT-FOUND)
    )
  )
)

;; Verify certification status
(define-public (verify-certification (cert-id uint))
  (match (map-get? certifications { cert-id: cert-id })
    cert
    (begin
      (if (> block-height (get expiry-timestamp cert))
        (begin
          (map-set certifications
            { cert-id: cert-id }
            (merge cert { status: STATUS-EXPIRED })
          )
          (err ERR-CERT-EXPIRED)
        )
        (ok (get status cert))
      )
    )
    (err ERR-CERT-NOT-FOUND)
  )
)

;; Read-only: get certification details
(define-read-only (get-certification (cert-id uint))
  (match (map-get? certifications { cert-id: cert-id })
    cert (ok cert)
    (err ERR-CERT-NOT-FOUND)
  )
)

;; Read-only: get audit trail
(define-read-only (get-audit-trail (cert-id uint) (audit-id uint))
  (match (map-get? audit-trail { cert-id: cert-id, audit-id: audit-id })
    audit (ok audit)
    (err ERR-CERT-NOT-FOUND)
  )
)

;; Read-only: get audit counter
(define-read-only (get-audit-counter (cert-id uint))
  (ok (default-to u0 (map-get? audit-counter { cert-id: cert-id })))
)

;; Read-only: get admin
(define-read-only (get-admin)
  (ok (var-get admin))
)

;; Read-only: check if paused
(define-read-only (is-paused)
  (ok (var-get paused))
)

;; Read-only: get total certifications
(define-read-only (get-total-certifications)
  (ok (var-get cert-counter))
)