;; User Verification Contract
;; Validates trading participants

(define-data-var admin principal tx-sender)

;; Map to store verified users
(define-map verified-users principal bool)

;; Error codes
(define-constant err-not-admin (err u100))
(define-constant err-already-verified (err u101))
(define-constant err-not-verified (err u102))

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; Verify a user
(define-public (verify-user (user principal))
  (begin
    (asserts! (is-admin) err-not-admin)
    (asserts! (is-none (map-get? verified-users user)) err-already-verified)
    (ok (map-set verified-users user true))))

;; Revoke verification
(define-public (revoke-verification (user principal))
  (begin
    (asserts! (is-admin) err-not-admin)
    (asserts! (is-some (map-get? verified-users user)) err-not-verified)
    (ok (map-delete verified-users user))))

;; Check if a user is verified
(define-read-only (is-verified (user principal))
  (default-to false (map-get? verified-users user)))

;; Transfer admin rights
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-admin) err-not-admin)
    (ok (var-set admin new-admin))))
