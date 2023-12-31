# cython: boundscheck = False
# cython: initializedcheck = False
# cython: wraparound = False
# cython: cdivision = True
# cython: language_level = 3

cimport numpy as np
from libc.math cimport exp, log1p, log

cdef extern from "gsl/gsl_randist.h" nogil:
    double gsl_ran_poisson_pdf(unsigned int k, double mu)
    

cpdef double logsumexp(double[:] arr) nogil

cdef inline double _logsumexp(double[:] arr) nogil:
    cdef:
        np.npy_intp n, N
        double out, max_val

    N = arr.shape[0]

    max_val = arr[0]
    for n in range(1, N):
        if max_val < arr[n]:
            max_val = arr[n]

    out = 0
    for n in range(N):
        out += exp(arr[n] - max_val)

    return max_val + log(out)

cpdef double log1pexp(double x) nogil

cdef inline double _log1pexp(double x) nogil:
    """
    Numerically stable implementation of log(1+exp(x)) aka softmax(0,x).

    Note: -log1pexp(-x) is log(sigmoid(x))

    Source:
    http://cran.r-project.org/web/packages/Rmpfr/vignettes/log1mexp-note.pdf
    """
    if x <= 18:
        return log1p(exp(x))
    elif 18 < x <= 33.3:
        return x + exp(-x)
    else:
        return x

cdef inline int _prod_int_vec(int[:] arr) nogil:
    cdef:
        np.npy_intp n, N
        int out

    out = 1
    N = arr.shape[0]
    for n in range(N):
        out *= arr[n]
    return out

cdef inline int _sum_int_vec(int[:] arr) nogil:
    cdef:
        np.npy_intp n, N
        int out

    out = 0
    N = arr.shape[0]
    for n in range(N):
        out += arr[n]
    return out

cdef inline int _sum_int_mat(int[:,:] arr) nogil:
    cdef:
        np.npy_intp n, m, N, M
        int out

    out = 0
    N, M = arr.shape[:2]
    for n in range(N):
        for m in range(M):
            out += arr[n, m]
    return out

cdef inline double _sum_double_vec(double[:] arr) nogil:
    cdef:
        np.npy_intp n, N
        double out

    out = 0
    N = arr.shape[0]
    for n in range(N):
        out += arr[n]
    return out

cdef inline double _sum_double_mat(double[:,:] arr) nogil:
    cdef:
        np.npy_intp n, m, N, M
        double out

    out = 0
    N, M = arr.shape[:2]
    for n in range(N):
        for m in range(M):
            out += arr[n, m]
    return out

cdef inline double _dot_vec(double[:] arr1, double[:] arr2) nogil:
    cdef:
        np.npy_intp n, N
        double out

    out = 0
    N = arr1.shape[0]
    for n in range(N):
        out += arr1[n] * arr2[n]
    return out

cpdef inline double _logpmf_poisson(int k, double mu) nogil:
    return log(gsl_ran_poisson_pdf(k, mu))