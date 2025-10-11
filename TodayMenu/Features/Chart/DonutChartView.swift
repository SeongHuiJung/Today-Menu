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
        drawChart()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !chartData.isEmpty {
            drawChart()
        }
    }
}

// MARK: - Gesture
extension DonutChartView {
    private func rotateChart(by angle: CGFloat, animated: Bool = false) {
        if animated {
            // 애니메이션과 함께 회전
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseOut, .allowUserInteraction]) {
                self.currentRotation = angle
                self.drawChart()
            }
        } else {
            currentRotation = angle
            drawChart()
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
                rotateChart(by: targetRotation, animated: true)
                return
            }
            accumulatedAngle += segmentAngle
        }
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
            var normalizedSelectionAngle = selectionAngle
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
