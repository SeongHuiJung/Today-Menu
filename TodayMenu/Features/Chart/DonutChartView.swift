//
//  DonutChartView.swift
//  TodayMenu
//
//  Created by 정성희 on 10/11/25.
//

import UIKit

final class DonutChartView: UIView {

    private var segmentLayers: [CAShapeLayer] = []
    private var chartData: [ChartDataModel] = []
    private var currentRotation: CGFloat = 0
    private var selectedIndex: Int = 0
    private var currentCellIndex: Int = 0
    private var labelViews: [UILabel] = [] // 차트 카테고리 이름 레이블 리스트
    private var isAnimating: Bool = false // 애니메이션 진행 중 여부
    private var hasDrawnInitialChart: Bool = false // 초기 차트 렌더링 여부

    private let colors: [UIColor] = [
        .point0,
        .point1,
        .point2,
        .point3
    ]

    // 선택 위치: 하단 중앙 (270도 = 3π/2)
    private let selectionAngle: CGFloat = CGFloat.pi / 2

    // 스와이프 감지를 위한 변수
    private var initialSwipeLocation: CGPoint = .zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestureRecognizer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupGestureRecognizer() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
    }

    func configure(with data: [ChartDataModel]) {
        self.chartData = data

        guard !data.isEmpty else {
            return
        }

        // 초기 상태: 첫 번째 셀이 하단 중앙에 오도록 설정
        currentCellIndex = 0

        // 첫 번째 셀의 중앙 각도 계산
        let firstSegmentAngle = 2 * CGFloat.pi * CGFloat(data[0].percentage)
        let firstCenterAngle = firstSegmentAngle / 2

        // 첫 번째 셀이 하단 중앙(π/2)에 오도록 회전 각도 설정
        currentRotation = CGFloat.pi - firstCenterAngle

        // 레이아웃이 완료된 후 차트와 레이블 표시
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // 초기 차트를 한 번만 그림
        guard !hasDrawnInitialChart, !chartData.isEmpty, bounds.width > 0, bounds.height > 0 else { return }
        hasDrawnInitialChart = true
        drawChart()

        // 레이블 표시
        self.showLabels()
    }
}

// MARK: - Gesture
extension DonutChartView {
    private func rotateChart(by angle: CGFloat, animated: Bool = false) {
        if animated {
            // 애니메이션 시작 시 레이블 숨기기
            isAnimating = true
            hideLabels()

            // 회전 애니메이션
            let steps = 30 // 애니메이션 프레임 수
            let duration: TimeInterval = 0.5
            let startRotation = currentRotation
            let endRotation = angle

            for i in 0...steps {
                let progress = CGFloat(i) / CGFloat(steps)
                let t = progress
                let easedProgress = 1 + 2.70158 * pow(t - 1, 3) + 1.70158 * pow(t - 1, 2)

                let delay = duration * Double(i) / Double(steps)

                DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                    guard let self = self else { return }
                    let interpolatedRotation = startRotation + (endRotation - startRotation) * easedProgress
                    self.currentRotation = interpolatedRotation
                    self.drawChart()

                    // 마지막 프레임에서 레이블 표시
                    if i == steps {
                        self.isAnimating = false
                        self.showLabels()
                    }
                }
            }
        } else {
            currentRotation = angle
            drawChart()
            if !isAnimating {
                showLabels()
            }
        }
    }

    private func hideLabels() {
        labelViews.forEach { $0.removeFromSuperview() }
        labelViews.removeAll()
    }

    private func showLabels() {
        guard !chartData.isEmpty else { return }

        hideLabels() // 기존 레이블 제거

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 20
        let innerRadius = radius * 0.6

        var accumulatedAngle: CGFloat = currentRotation - CGFloat.pi / 2

        for (_, data) in chartData.enumerated() {
            let segmentAngle = 2 * CGFloat.pi * CGFloat(data.percentage)
            let midAngle = accumulatedAngle + segmentAngle / 2

            // 레이블 텍스트
            let percentageText = String(format: "%.0f%%", data.percentage * 100)
            let labelText = "\(data.label) \(percentageText)"

            let label = UILabel()
            label.text = labelText
            label.font = .systemFont(ofSize: 14, weight: .semibold)
            label.textColor = .label
            label.textAlignment = .center
            label.sizeToFit()

            // 셀이 작으면 바깥쪽에 배치
            let minPercentageForInside: Double = 0.15 // 15% 이상이면 안쪽
            let labelRadius: CGFloat

            if data.percentage >= minPercentageForInside {
                // 셀 안쪽 (도넛 중간)
                labelRadius = (radius + innerRadius) / 2
            } else {
                // 셀 바깥쪽
                labelRadius = radius + 40
            }

            // 레이블 위치 계산
            let labelX = center.x + labelRadius * cos(midAngle)
            let labelY = center.y + labelRadius * sin(midAngle)

            // frame을 사용하여 레이아웃 사이클 방지
            let labelSize = label.bounds.size
            label.frame = CGRect(
                x: labelX - labelSize.width / 2,
                y: labelY - labelSize.height / 2,
                width: labelSize.width,
                height: labelSize.height
            )

            addSubview(label)
            labelViews.append(label)

            accumulatedAngle += segmentAngle
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard !chartData.isEmpty else { return }

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let location = gesture.location(in: self)

        switch gesture.state {
        case .began:
            // 시작 위치 저장
            initialSwipeLocation = location
            layer.removeAllAnimations()

        case .ended, .cancelled:
            // 페이징 스크롤: 제스처 방향에 따라 다음/이전 셀로 이동

            // 중심에서 각 터치 위치로의 벡터
            let startVector = CGPoint(
                x: initialSwipeLocation.x - center.x,
                y: initialSwipeLocation.y - center.y
            )
            let endVector = CGPoint(
                x: location.x - center.x,
                y: location.y - center.y
            )

            // 외적(cross product)을 사용하여 회전 방향 감지
            // UIKit 좌표계에서 crossProduct < 0: 시계 방향, crossProduct > 0: 반시계 방향
            let crossProduct = startVector.x * endVector.y - startVector.y * endVector.x

            // 최소 스와이프 감지 임계값 (벡터 크기 기준)
            let swipeThreshold: CGFloat = 500.0

            if abs(crossProduct) > swipeThreshold {
                if crossProduct < 0 {
                    // 시계 방향으로 회전 → 다음 셀
                    moveToNextCell()
                } else {
                    // 반시계 방향으로 회전 → 이전 셀
                    moveToPreviousCell()
                }
            } else {
                // 스와이프가 충분하지 않으면 현재 셀 유지
                snapToCurrentCell()
            }

        default:
            break
        }
    }

    private func moveToNextCell() {
        let nextIndex = (currentCellIndex + 1) % chartData.count
        currentCellIndex = nextIndex
        snapToCurrentCell()
    }

    private func moveToPreviousCell() {
        let previousIndex = (currentCellIndex - 1 + chartData.count) % chartData.count
        currentCellIndex = previousIndex
        snapToCurrentCell()
    }

    private func snapToCurrentCell() {
        // 현재 셀의 중앙으로 다시 스냅
        var accumulatedAngle: CGFloat = 0
        for (index, data) in chartData.enumerated() {
            let segmentAngle = 2 * CGFloat.pi * CGFloat(data.percentage)
            if index == currentCellIndex {
                let centerAngle = accumulatedAngle + segmentAngle / 2
                let targetRotation = CGFloat.pi - centerAngle

                // 최단 경로로 회전하도록 각도 조정
                let adjustedTarget = findShortestRotationPath(from: currentRotation, to: targetRotation)

                rotateChart(by: adjustedTarget, animated: true)
                return
            }
            accumulatedAngle += segmentAngle
        }
    }

    private func findShortestRotationPath(from currentAngle: CGFloat, to targetAngle: CGFloat) -> CGFloat {
        // 현재 각도와 목표 각도의 차이 계산
        var delta = targetAngle - currentAngle

        // 차이를 -π ~ π 범위로 정규화 (최단 경로)
        while delta > CGFloat.pi {
            delta -= 2 * CGFloat.pi
        }
        while delta < -CGFloat.pi {
            delta += 2 * CGFloat.pi
        }

        // 최단 경로로 이동할 목표 각도 반환
        return currentAngle + delta
    }

    
    private func drawChart() {
        guard !chartData.isEmpty else { return }

        // 기존 레이어 모두 제거
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        segmentLayers.removeAll()

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 20
        let innerRadius = radius * 0.6 // 도넛 형태를 위한 내부 반지름

        // 누적 각도 추적
        var currentAngle: CGFloat = currentRotation - CGFloat.pi / 2

        // 하단 중앙(270도)에 위치한 섹터 찾기
        selectedIndex = -1
        var accumulatedAngle: CGFloat = currentRotation - CGFloat.pi / 2

        for (index, data) in chartData.enumerated() {
            let segmentAngle = 2 * CGFloat.pi * CGFloat(data.percentage)
            let endAngle = accumulatedAngle + segmentAngle

            // 선택 각도 정규화
            let normalizedSelectionAngle = selectionAngle
            var normalizedStartAngle = accumulatedAngle
            var normalizedEndAngle = endAngle

            // 각도를 0 ~ 2π 범위로 정규화
            while normalizedStartAngle < 0 { normalizedStartAngle += 2 * CGFloat.pi }
            while normalizedStartAngle >= 2 * CGFloat.pi { normalizedStartAngle -= 2 * CGFloat.pi }
            while normalizedEndAngle < 0 { normalizedEndAngle += 2 * CGFloat.pi }
            while normalizedEndAngle >= 2 * CGFloat.pi { normalizedEndAngle -= 2 * CGFloat.pi }

            // 선택 각도가 현재 섹터 범위 내에 있는지 확인
            if normalizedStartAngle <= normalizedEndAngle {
                if normalizedSelectionAngle >= normalizedStartAngle && normalizedSelectionAngle <= normalizedEndAngle {
                    selectedIndex = index
                }
            } else {
                // 섹터가 0도를 넘어가는 경우
                if normalizedSelectionAngle >= normalizedStartAngle || normalizedSelectionAngle <= normalizedEndAngle {
                    selectedIndex = index
                }
            }

            accumulatedAngle = endAngle
        }

        // 차트 그리기
        currentAngle = currentRotation - CGFloat.pi / 2

        for (index, data) in chartData.enumerated() {
            // 비율에 따라 각도 계산
            let segmentAngle = 2 * CGFloat.pi * CGFloat(data.percentage)
            let startAngle = currentAngle
            let endAngle = currentAngle + segmentAngle

            // 외부 원호
            let outerPath = UIBezierPath(
                arcCenter: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: true
            )

            // 내부 원호 (반대 방향)
            outerPath.addArc(
                withCenter: center,
                radius: innerRadius,
                startAngle: endAngle,
                endAngle: startAngle,
                clockwise: false
            )

            outerPath.close()

            // 레이어 생성 및 추가
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = outerPath.cgPath

            // 선택된 섹터는 진하게 표시
            let baseColor = colors[index % colors.count]
            if index == selectedIndex {
                shapeLayer.fillColor = baseColor.withAlphaComponent(1.0).cgColor
                shapeLayer.shadowColor = UIColor.point1.cgColor
                shapeLayer.shadowOffset = CGSize(width: 0, height: 0)
                shapeLayer.shadowOpacity = 0.8
                shapeLayer.shadowRadius = 6
            } else {
                shapeLayer.fillColor = baseColor.withAlphaComponent(0.5).cgColor
            }

            shapeLayer.strokeColor = UIColor.white.cgColor
            shapeLayer.lineWidth = 2

            layer.addSublayer(shapeLayer)
            segmentLayers.append(shapeLayer)

            // 다음 섹션을 위해 각도 업데이트
            currentAngle = endAngle
        }

        // 중앙 원 (도넛 홀)
        let centerCircle = CAShapeLayer()
        let centerPath = UIBezierPath(
            arcCenter: center,
            radius: innerRadius,
            startAngle: 0,
            endAngle: 2 * CGFloat.pi,
            clockwise: true
        )
        centerCircle.path = centerPath.cgPath
        centerCircle.fillColor = UIColor.systemBackground.cgColor
        layer.addSublayer(centerCircle)

        // 선택 표시 마커 추가 (하단 중앙)
        addSelectionMarker(at: center, radius: radius)
    }

    private func addSelectionMarker(at center: CGPoint, radius: CGFloat) {
        // 하단 중앙에 작은 삼각형 마커 표시
        let markerSize: CGFloat = 15
        let markerDistance = radius + 10

        let markerX = center.x
        let markerY = center.y + markerDistance

        let markerPath = UIBezierPath()
        markerPath.move(to: CGPoint(x: markerX, y: markerY))
        markerPath.addLine(to: CGPoint(x: markerX - markerSize / 2, y: markerY + markerSize))
        markerPath.addLine(to: CGPoint(x: markerX + markerSize / 2, y: markerY + markerSize))
        markerPath.close()

        let markerLayer = CAShapeLayer()
        markerLayer.path = markerPath.cgPath
        markerLayer.fillColor = UIColor.label.cgColor

        layer.addSublayer(markerLayer)
    }
}
