;; Asset Listing Contract
;; Records tradable tokens

(define-data-var admin principal tx-sender)

;; Asset structure
(define-map listed-assets
  { asset-id: uint }
  {
    name: (string-ascii 32),
    symbol: (string-ascii 10),
    contract-address: principal,
    active: bool
  })

;; Asset counter
(define-data-var asset-counter uint u0)

;; Error codes
(define-constant err-not-admin (err u100))
(define-constant err-asset-not-found (err u101))
(define-constant err-asset-already-exists (err u102))

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; List a new asset
(define-public (list-asset
  (name (string-ascii 32))
  (symbol (string-ascii 10))
  (contract-address principal))
  (let ((asset-id (var-get asset-counter)))
    (begin
      (asserts! (is-admin) err-not-admin)
      (var-set asset-counter (+ asset-id u1))
      (ok (map-set listed-assets
        { asset-id: asset-id }
        {
          name: name,
          symbol: symbol,
          contract-address: contract-address,
          active: true
        })))))

;; Deactivate an asset
(define-public (deactivate-asset (asset-id uint))
  (let ((asset (map-get? listed-assets { asset-id: asset-id })))
    (begin
      (asserts! (is-admin) err-not-admin)
      (asserts! (is-some asset) err-asset-not-found)
      (ok (map-set listed-assets
        { asset-id: asset-id }
        (merge (unwrap-panic asset) { active: false }))))))

;; Reactivate an asset
(define-public (reactivate-asset (asset-id uint))
  (let ((asset (map-get? listed-assets { asset-id: asset-id })))
    (begin
      (asserts! (is-admin) err-not-admin)
      (asserts! (is-some asset) err-asset-not-found)
      (ok (map-set listed-assets
        { asset-id: asset-id }
        (merge (unwrap-panic asset) { active: true }))))))

;; Get asset details
(define-read-only (get-asset (asset-id uint))
  (map-get? listed-assets { asset-id: asset-id }))

;; Check if asset is active
(define-read-only (is-asset-active (asset-id uint))
  (default-to
    false
    (get active (map-get? listed-assets { asset-id: asset-id }))))

;; Transfer admin rights
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-admin) err-not-admin)
    (ok (var-set admin new-admin))))
