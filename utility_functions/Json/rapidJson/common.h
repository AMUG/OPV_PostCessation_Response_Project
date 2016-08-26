#pragma once

void ValidateArguments(int nlhs, int nrhs, const mxArray* prhs[], const char* module);
void GetFilenameFromArguments(const mxArray* prhs[], char*& filename);
void ReadParseJsonFile(const char* filename, Document& document);

#define MXFREE(_ptr)    { if (_ptr) { mxFree(_ptr); _ptr = nullptr; }}
