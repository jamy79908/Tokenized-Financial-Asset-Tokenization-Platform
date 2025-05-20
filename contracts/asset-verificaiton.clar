;; Asset Verification Contract
;; Validates the existence and details of underlying assets

(define-data-var contract-owner principal tx-sender)

;; Asset data structure
(define-map assets
  { asset-id: (string-ascii 36) }
  {
    name: (string-ascii 64),
    description: (string-ascii 256),
    value: uint,
    verified: bool,
    verifier: principal,
    verification-date: uint
  }
)

;; Check if caller is contract owner
(define-private (is-contract-owner)
  (is-eq tx-sender (var-get contract-owner))
)

;; Register a new asset
(define-public (register-asset (asset-id (string-ascii 36)) (name (string-ascii 64)) (description (string-ascii 256)) (value uint))
  (begin
    (asserts! (is-contract-owner) (err u1))
    (map-insert assets
      { asset-id: asset-id }
      {
        name: name,
        description: description,
        value: value,
        verified: false,
        verifier: tx-sender,
        verification-date: u0
      }
    )
    (ok true)
  )
)

;; Verify an asset
(define-public (verify-asset (asset-id (string-ascii 36)))
  (let (
    (asset (unwrap! (map-get? assets { asset-id: asset-id }) (err u2)))
  )
    (begin
      (asserts! (is-contract-owner) (err u1))
      (map-set assets
        { asset-id: asset-id }
        (merge asset {
          verified: true,
          verifier: tx-sender,
          verification-date: block-height
        })
      )
      (ok true)
    )
  )
)

;; Get asset details
(define-read-only (get-asset (asset-id (string-ascii 36)))
  (map-get? assets { asset-id: asset-id })
)

;; Check if asset is verified
(define-read-only (is-asset-verified (asset-id (string-ascii 36)))
  (default-to false (get verified (map-get? assets { asset-id: asset-id })))
)
