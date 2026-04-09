; ModuleID = 'attack/main.c'
source_filename = "attack/main.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@__const.main.array1 = private unnamed_addr constant [4 x i32] [i32 1, i32 2, i32 3, i32 4], align 16
@__const.main.array2 = private unnamed_addr constant [4 x i32] [i32 5, i32 6, i32 7, i32 8], align 16
@.str = private unnamed_addr constant [15 x i8] c"attack_success\00", align 1
@.str.1 = private unnamed_addr constant [14 x i8] c"attack/main.c\00", align 1
@__PRETTY_FUNCTION__.main = private unnamed_addr constant [11 x i8] c"int main()\00", align 1
@.str.2 = private unnamed_addr constant [52 x i8] c"successfully escalated privilege of stack pointer:\0A\00", align 1
@.str.3 = private unnamed_addr constant [49 x i8] c"    array%d exists at : %p with values:\0A        \00", align 1
@.str.4 = private unnamed_addr constant [4 x i8] c"%d \00", align 1
@.str.5 = private unnamed_addr constant [2 x i8] c"\0A\00", align 1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca [4 x i32], align 16          %2 --> fp
  %3 = alloca [4 x i32], align 16
  %4 = alloca [1 x i32*], align 8          %4 --> fp + 16
  %5 = alloca i32*, align 8
  %6 = alloca i32, align 4
  %7 = alloca [2 x i32*], align 16
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %10 = bitcast [4 x i32]* %2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %10, i8* align 16 bitcast ([4 x i32]* @__const.main.array1 to i8*), i64 16, i1 false)
  %11 = bitcast [4 x i32]* %3 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %11, i8* align 16 bitcast ([4 x i32]* @__const.main.array2 to i8*), i64 16, i1 false)
  %12 = getelementptr inbounds [1 x i32*], [1 x i32*]* %4, i64 0, i64 0          %12 --> fp + 16
  %13 = getelementptr inbounds [4 x i32], [4 x i32]* %2, i64 0, i64 0            %13 --> fp 
  store i32* %13, i32** %12, align 8                                             *%12 --> fp   
  %14 = getelementptr inbounds [1 x i32*], [1 x i32*]* %4, i64 0, i64 0          %14 --> fp + 16
  %15 = bitcast i32** %14 to i8*                                                 %15 --> fp + 16
  call void @overwrite_metadata_map(i8* %15, i32 4)
  %16 = getelementptr inbounds [1 x i32*], [1 x i32*]* %4, i64 0, i64 0           %16 --> fp + 16
  %17 = load i32*, i32** %16, align 8                                           %17 --> // here, problem; don't have *%16 stored
  store i32* %17, i32** %5, align 8
  %18 = load i32*, i32** %5, align 8
  %19 = getelementptr inbounds i32, i32* %18, i64 4
  store i32 37, i32* %19, align 4
  %20 = getelementptr inbounds [4 x i32], [4 x i32]* %3, i64 0, i64 0
  %21 = load i32, i32* %20, align 16
  %22 = icmp eq i32 %21, 37
  %23 = zext i1 %22 to i32
  store i32 %23, i32* %6, align 4
  %24 = load i32, i32* %6, align 4
  %25 = icmp ne i32 %24, 0
  br i1 %25, label %26, label %27

26:                                               ; preds = %0
  br label %28

27:                                               ; preds = %0
  call void @__assert_fail(i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str, i64 0, i64 0), i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i64 0, i64 0), i32 29, i8* getelementptr inbounds ([11 x i8], [11 x i8]* @__PRETTY_FUNCTION__.main, i64 0, i64 0)) #4
  unreachable

28:                                               ; preds = %26
  %29 = getelementptr inbounds [2 x i32*], [2 x i32*]* %7, i64 0, i64 0
  %30 = getelementptr inbounds [4 x i32], [4 x i32]* %2, i64 0, i64 0
  store i32* %30, i32** %29, align 8
  %31 = getelementptr inbounds i32*, i32** %29, i64 1
  %32 = getelementptr inbounds [4 x i32], [4 x i32]* %3, i64 0, i64 0
  store i32* %32, i32** %31, align 8
  %33 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([52 x i8], [52 x i8]* @.str.2, i64 0, i64 0))
  store i32 0, i32* %8, align 4
  br label %34

34:                                               ; preds = %63, %28
  %35 = load i32, i32* %8, align 4
  %36 = icmp slt i32 %35, 2
  br i1 %36, label %37, label %66

37:                                               ; preds = %34
  %38 = load i32, i32* %8, align 4
  %39 = add nsw i32 %38, 1
  %40 = load i32, i32* %8, align 4
  %41 = sext i32 %40 to i64
  %42 = getelementptr inbounds [2 x i32*], [2 x i32*]* %7, i64 0, i64 %41
  %43 = load i32*, i32** %42, align 8
  %44 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([49 x i8], [49 x i8]* @.str.3, i64 0, i64 0), i32 %39, i32* %43)
  store i32 0, i32* %9, align 4
  br label %45

45:                                               ; preds = %58, %37
  %46 = load i32, i32* %9, align 4
  %47 = icmp slt i32 %46, 4
  br i1 %47, label %48, label %61

48:                                               ; preds = %45
  %49 = load i32, i32* %8, align 4
  %50 = sext i32 %49 to i64
  %51 = getelementptr inbounds [2 x i32*], [2 x i32*]* %7, i64 0, i64 %50
  %52 = load i32*, i32** %51, align 8
  %53 = load i32, i32* %9, align 4
  %54 = sext i32 %53 to i64
  %55 = getelementptr inbounds i32, i32* %52, i64 %54
  %56 = load i32, i32* %55, align 4
  %57 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.4, i64 0, i64 0), i32 %56)
  br label %58

58:                                               ; preds = %48
  %59 = load i32, i32* %9, align 4
  %60 = add nsw i32 %59, 1
  store i32 %60, i32* %9, align 4
  br label %45, !llvm.loop !2

61:                                               ; preds = %45
  %62 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str.5, i64 0, i64 0))
  br label %63

63:                                               ; preds = %61
  %64 = load i32, i32* %8, align 4
  %65 = add nsw i32 %64, 1
  store i32 %65, i32* %8, align 4
  br label %34, !llvm.loop !4

66:                                               ; preds = %34
  ret i32 0
}

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

declare dso_local void @overwrite_metadata_map(i8*, i32) #2

; Function Attrs: noreturn nounwind
declare dso_local void @__assert_fail(i8*, i8*, i32, i8*) #3

declare dso_local i32 @printf(i8*, ...) #2

attributes #0 = { noinline nounwind optnone uwtable "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nofree nosync nounwind willreturn }
attributes #2 = { "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { noreturn nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { noreturn nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 12.0.1 (git@github.com:parthsarkar17/softboundcets-ese5370.git de5fa15ccb0fe927b0ccac18cfb91b220d4ccb3e)"}
!2 = distinct !{!2, !3}
!3 = !{!"llvm.loop.mustprogress"}
!4 = distinct !{!4, !3}
