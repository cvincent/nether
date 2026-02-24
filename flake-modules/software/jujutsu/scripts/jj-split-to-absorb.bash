jj split -B @ --message absorb "$@"
jj absorb --from @-
jj squash --from @- --to @ --use-destination-message
