!===============IDENTIFICATION DIVISION====================

!-------------TO FIND THE INTERPOLATION INDEX----------------

SUBROUTINE binary_search(head, tail, needle, haystack, size, decreasing)

  IMPLICIT NONE

  INTEGER, INTENT(out) :: head
  INTEGER, INTENT(out) :: tail
  REAL, INTENT(in) :: needle
  INTEGER :: size
  !f2py INTEGER, INTENT(hide), DEPEND(haystack) :: size = len(haystack)
  REAL, INTENT(in), DIMENSION(size) :: haystack
  LOGICAL, INTENT(in) :: decreasing

  INTEGER range
  INTEGER middle

  REAL comparison

  head = 1
  tail = size
  range = tail - head
  middle = (tail + head) / 2

  IF (decreasing) THEN
    comparison = -1.
  ELSE
    comparison = 1.
  END IF

  DO WHILE ( haystack(middle) /= needle .AND. range > 1)
    IF (SIGN(1., needle - haystack(middle)) == comparison) THEN
      head = middle
    ELSE
      tail = middle
    END IF

    range = tail - head
    middle = (tail + head) / 2
  END DO

  IF (haystack(middle) == needle) THEN
    head = middle
    tail = middle
  ELSE IF (haystack(head) == needle) THEN
    tail = head
  ELSE IF (haystack(tail) == needle) THEN
    head = tail
  END IF


END SUBROUTINE binary_search

!-------THE FUNCTIONS DOING AN INTERPOLATION---------------

SUBROUTINE interp_values(interp_val, x_interp, x_values, y_values, decreasing, nlines)

  IMPLICIT NONE

  REAL, INTENT(out) :: interp_val
  !The interpolated y-result
  REAL, INTENT(in) :: x_interp
  !The x-value at which interpolation happens
  REAL, INTENT(in) :: x_values(nlines)
  !The abscissa discrete values
  REAL, INTENT(in) :: y_values(nlines)
  !The array for which we interpolate
  LOGICAL, INTENT(in) :: decreasing
  !This boolean tells if the x-values are in decreasing (true) or incr. order
  INTEGER, INTENT(in) :: nlines


  INTEGER head, tail
  !The integer giving an x-value just below the one to be interpolated

  REAL :: x_lo, x_up, y_lo, y_up

  CALL binary_search(head, tail, x_interp, x_values, nlines, decreasing)

  IF (head /= tail) THEN

    y_lo = y_values(head)
    y_up = y_values(tail)
    x_lo = x_values(head)
    x_up = x_values(tail)

    interp_val = ( (x_up-x_interp)*y_lo + (x_interp-x_lo)*y_up ) / (x_up - x_lo)
  ELSE
    interp_val = y_values(head)
  END IF

END SUBROUTINE

!--------FOR A LOGARITHMIC INTERPOLATION---------------------
! We will usually do an interpolation of the log of the values as these
!  values are rapidly varying, instead of simply doing a linear interp.
SUBROUTINE log_interp_values(interp_val, x_interp, x_values, y_values, decreasing, nlines)

  IMPLICIT NONE

  REAL, INTENT(out) :: interp_val
  !The interpolated y-result
  REAL, INTENT(in) :: x_interp
  !The x-value at which interpolation happens
  REAL, INTENT(in), DIMENSION(nlines) :: x_values
  !The abscissa
  REAL, INTENT(in), DIMENSION(nlines) :: y_values
  !The array for which we interpolate
  LOGICAL, INTENT(in) :: decreasing
  !This boolean tells if the x-values are in decreasing (true) or incr. order
  INTEGER, INTENT(in) :: nlines

  INTEGER head, tail
  !The integer giving an x-value just below the one to be interpolated
  LOGICAL positive
  !This tells if the y_values are positive, needed when taking the log.

  REAL x_lo, x_up, y_lo, y_up


  CALL binary_search(head, tail, x_interp, x_values, nlines, decreasing)

  IF (head == tail) THEN
    interp_val = y_values(head)
  ELSE
    y_lo = y_values(head)
    y_up = y_values(tail)

    IF ( y_lo*y_up <= 0 ) THEN
    ! It is not possible to take the log if one of them is 0 or if they
    ! have different signs, so we do a linear interpolation in this case
       CALL interp_values(interp_val, x_interp, x_values, y_values, decreasing, nlines)
    ELSE
       positive = .true.
       IF (y_lo < 0) THEN
          positive = .false.
          y_lo = -y_lo        !For negative numbers we take the log
          y_up = -y_up        ! of their opposite
       END IF

       y_lo = log(y_lo)
       y_up = log(y_up)
       x_lo = x_values(head)
       x_up = x_values(tail)

       interp_val = ( (x_up-x_interp)*y_lo + (x_interp-x_lo)*y_up ) / (x_up - x_lo)

       interp_val = exp(interp_val)

       IF (.not.positive) THEN
          interp_val = -interp_val
       END IF

    END IF

  END IF

END SUBROUTINE
